<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Estudiante;
use App\Models\Carrera;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class EstudianteAdminController extends Controller
{
    /**
     * Listar todos los estudiantes con filtros
     */
    public function index(Request $request)
    {
        $estudiantes = Estudiante::with(['carrera', 'user'])
        ->when($request->search, function ($query, $search) {
            return $query->where('nombres', 'LIKE', "%$search%")
            ->orWhere('apellido_paterno', 'LIKE', "%$search%")
            ->orWhere('apellido_materno', 'LIKE', "%$search%")
            ->orWhere('dni', 'LIKE', "%$search%")
            ->orWhere('email', 'LIKE', "%$search%");
        })
        ->when($request->carrera_id, function ($query, $carreraId) {
            return $query->where('carrera_id', $carreraId);
        })
        ->when($request->estado, function ($query, $estado) {
            return $query->where('estado', $estado);
        })
        ->orderBy('id', 'desc')
        ->paginate($request->per_page ?? 20);

        return response()->json([
            'success' => true,
            'data' => $estudiantes,
            'message' => 'Lista de estudiantes obtenida correctamente'
        ]);
    }

    /**
     * Obtener un estudiante específico
     */
    public function show($id)
    {
        $estudiante = Estudiante::with(['carrera', 'user', 'matriculas', 'admisiones'])->find($id);

        if (!$estudiante) {
            return response()->json([
                'success' => false,
                'message' => 'Estudiante no encontrado'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $estudiante,
            'message' => 'Estudiante obtenido correctamente'
        ]);
    }

    /**
     * Crear un nuevo estudiante
     */
    public function store(Request $request)
    {
        $request->validate([
            'nombres' => 'required|string|max:255',
            'apellido_paterno' => 'required|string|max:255',
            'apellido_materno' => 'required|string|max:255',
            'dni' => 'required|string|size:8|unique:estudiantes,dni',
            'email' => 'nullable|email|unique:estudiantes,email',
            'celular' => 'nullable|string|max:15',
            'carrera_id' => 'required|exists:carreras,id',
            'estado' => 'required|in:activo,inactivo',
            'crear_usuario' => 'boolean'
        ]);

        // Generar código automático
        $codigo = $this->generarCodigo();

        $estudiante = Estudiante::create([
            'codigo' => $codigo,
            'nombres' => $request->nombres,
            'apellido_paterno' => $request->apellido_paterno,
            'apellido_materno' => $request->apellido_materno,
            'dni' => $request->dni,
            'email' => $request->email,
            'celular' => $request->celular,
            'carrera_id' => $request->carrera_id,
            'estado' => $request->estado,
        ]);

        // Crear usuario automáticamente si se solicita
        if ($request->crear_usuario && $request->email) {
            $user = User::create([
                'name' => $request->nombres . ' ' . $request->apellido_paterno,
                'email' => $request->email,
                'password' => Hash::make($request->dni), // Password = DNI
                                 'rol' => 'estudiante',
                                 'dni' => $request->dni,
                                 'activo' => true
            ]);
            $estudiante->user_id = $user->id;
            $estudiante->save();
        }

        return response()->json([
            'success' => true,
            'data' => $estudiante->fresh(['carrera', 'user']),
                                'message' => 'Estudiante creado correctamente'
        ], 201);
    }

    /**
     * Actualizar un estudiante
     */
    public function update(Request $request, $id)
    {
        $estudiante = Estudiante::find($id);

        if (!$estudiante) {
            return response()->json([
                'success' => false,
                'message' => 'Estudiante no encontrado'
            ], 404);
        }

        $request->validate([
            'nombres' => 'sometimes|string|max:255',
            'apellido_paterno' => 'sometimes|string|max:255',
            'apellido_materno' => 'sometimes|string|max:255',
            'dni' => 'sometimes|string|size:8|unique:estudiantes,dni,' . $id,
            'email' => 'nullable|email|unique:estudiantes,email,' . $id,
            'celular' => 'nullable|string|max:15',
            'carrera_id' => 'sometimes|exists:carreras,id',
            'estado' => 'sometimes|in:activo,inactivo',
        ]);

        $estudiante->update($request->all());

        // Actualizar email del usuario asociado si existe
        if ($estudiante->user && $request->has('email')) {
            $estudiante->user->update(['email' => $request->email]);
        }

        return response()->json([
            'success' => true,
            'data' => $estudiante->fresh(['carrera', 'user']),
                                'message' => 'Estudiante actualizado correctamente'
        ]);
    }

    /**
     * Eliminar un estudiante
     */
    public function destroy($id)
    {
        $estudiante = Estudiante::find($id);

        if (!$estudiante) {
            return response()->json([
                'success' => false,
                'message' => 'Estudiante no encontrado'
            ], 404);
        }

        // Verificar si tiene registros relacionados
        if ($estudiante->matriculas()->count() > 0 || $estudiante->admisiones()->count() > 0) {
            return response()->json([
                'success' => false,
                'message' => 'No se puede eliminar el estudiante porque tiene registros relacionados'
            ], 409);
        }

        // Eliminar usuario asociado si existe
        if ($estudiante->user) {
            $estudiante->user->delete();
        }

        $estudiante->delete();

        return response()->json([
            'success' => true,
            'message' => 'Estudiante eliminado correctamente'
        ]);
    }

    /**
     * Estadísticas de estudiantes
     */
    public function stats()
    {
        $total = Estudiante::count();
        $activos = Estudiante::where('estado', 'activo')->count();
        $inactivos = Estudiante::where('estado', 'inactivo')->count();
        $conUsuario = Estudiante::whereNotNull('user_id')->count();
        $sinUsuario = Estudiante::whereNull('user_id')->count();

        $porCarrera = DB::table('estudiantes')
        ->join('carreras', 'estudiantes.carrera_id', '=', 'carreras.id')
        ->select('carreras.nombre', DB::raw('count(*) as total'))
        ->groupBy('carreras.nombre')
        ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'total' => $total,
                'activos' => $activos,
                'inactivos' => $inactivos,
                'con_usuario' => $conUsuario,
                'sin_usuario' => $sinUsuario,
                'por_carrera' => $porCarrera,
            ]
        ]);
    }

    /**
     * Obtener estudiantes sin usuario asociado
     */
    public function sinUsuario()
    {
        $estudiantes = Estudiante::whereNull('user_id')
        ->with(['carrera'])
        ->get();

        return response()->json([
            'success' => true,
            'data' => $estudiantes,
            'message' => 'Estudiantes sin usuario obtenidos correctamente'
        ]);
    }

    /**
     * Generar código único para estudiante
     */
    private function generarCodigo()
    {
        $year = date('Y');
        $last = Estudiante::where('codigo', 'LIKE', "EST-{$year}-%")
        ->orderBy('codigo', 'desc')
        ->first();

        if ($last) {
            $number = intval(substr($last->codigo, -4)) + 1;
            $number = str_pad($number, 4, '0', STR_PAD_LEFT);
        } else {
            $number = '0001';
        }

        return "EST-{$year}-{$number}";
    }
}
