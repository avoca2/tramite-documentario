<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Admision;
use App\Models\Estudiante;
use App\Models\Carrera;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AdmisionController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        try {
            $admisiones = Admision::with(['estudiante', 'estudiante.carrera'])
                ->orderBy('created_at', 'desc')
                ->get()
                ->map(function ($admision) {
                    return [
                        'id' => $admision->id,
                        'estudiante_id' => $admision->estudiante_id,
                        'estudiante_nombre' => $admision->estudiante ? $admision->estudiante->nombre_completo : 'N/A',
                        'dni' => $admision->estudiante ? $admision->estudiante->dni : 'N/A',
                        'modalidad' => $admision->modalidad,
                        'nota_final' => $admision->nota_final,
                        'estado' => $admision->estado,
                        'lugar_procedencia' => $admision->lugar_procedencia,
                        'colegio_procedencia' => $admision->colegio_procedencia,
                        'observaciones' => $admision->observaciones,
                        'fecha_inscripcion' => $admision->created_at,
                        'fecha_evaluacion' => $admision->fecha_evaluacion,
                        'created_at' => $admision->created_at,
                        'updated_at' => $admision->updated_at,
                    ];
                });

            return response()->json($admisiones);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al obtener admisiones',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'dni' => 'required|string|size:8',
                'nombres' => 'required|string|max:100',
                'apellido_paterno' => 'required|string|max:50',
                'apellido_materno' => 'required|string|max:50',
                'celular' => 'required|string|max:15',
                'email' => 'required|email|max:100',
                'modalidad' => 'required|in:ordinaria,exoneracion',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Error de validación',
                    'errors' => $validator->errors()
                ], 422);
            }

            DB::beginTransaction();

            // Buscar o crear estudiante
            $estudiante = Estudiante::where('dni', $request->dni)->first();

            if (!$estudiante) {
                // Crear nuevo estudiante
                $estudiante = Estudiante::create([
                    'dni' => $request->dni,
                    'nombres' => $request->nombres,
                    'apellido_paterno' => $request->apellido_paterno,
                    'apellido_materno' => $request->apellido_materno,
                    'fecha_nacimiento' => $request->fecha_nacimiento ?? null,
                    'celular' => $request->celular,
                    'email' => $request->email,
                    'direccion' => $request->direccion,
                    'carrera_id' => $request->carrera_id ?? null,
                    'codigo_estudiante' => 'EST-' . date('Y') . '-' . str_pad(Estudiante::count() + 1, 4, '0', STR_PAD_LEFT),
                    'estado' => 'activo',
                ]);
            }

            // Verificar si ya tiene una admisión activa
            $admisionExistente = Admision::where('estudiante_id', $estudiante->id)
                ->whereIn('estado', ['inscrito', 'evaluado'])
                ->first();

            if ($admisionExistente) {
                return response()->json([
                    'message' => 'El estudiante ya tiene un proceso de admisión activo',
                    'admision' => $admisionExistente
                ], 409);
            }

            // Crear admisión
            $admision = Admision::create([
                'estudiante_id' => $estudiante->id,
                'modalidad' => $request->modalidad,
                'estado' => 'inscrito',
                'lugar_procedencia' => $request->lugar_procedencia,
                'colegio_procedencia' => $request->colegio_procedencia,
                'observaciones' => $request->observaciones,
                'fecha_inscripcion' => now(),
            ]);

            DB::commit();

            return response()->json([
                'message' => 'Inscripción exitosa',
                'id' => $admision->id,
                'estudiante' => $estudiante,
                'admision' => $admision
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Error al inscribir',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        try {
            $admision = Admision::with(['estudiante', 'estudiante.carrera'])->find($id);

            if (!$admision) {
                return response()->json(['message' => 'Admisión no encontrada'], 404);
            }

            return response()->json([
                'id' => $admision->id,
                'estudiante_id' => $admision->estudiante_id,
                'estudiante_nombre' => $admision->estudiante ? $admision->estudiante->nombre_completo : 'N/A',
                'dni' => $admision->estudiante ? $admision->estudiante->dni : 'N/A',
                'modalidad' => $admision->modalidad,
                'nota_final' => $admision->nota_final,
                'estado' => $admision->estado,
                'lugar_procedencia' => $admision->lugar_procedencia,
                'colegio_procedencia' => $admision->colegio_procedencia,
                'observaciones' => $admision->observaciones,
                'fecha_inscripcion' => $admision->created_at,
                'fecha_evaluacion' => $admision->fecha_evaluacion,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al obtener admisión',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        try {
            $admision = Admision::find($id);

            if (!$admision) {
                return response()->json(['message' => 'Admisión no encontrada'], 404);
            }

            $validator = Validator::make($request->all(), [
                'modalidad' => 'sometimes|in:ordinaria,exoneracion',
                'nota_final' => 'sometimes|numeric|min:0|max:20',
                'estado' => 'sometimes|in:inscrito,evaluado,ingresante,no_ingresante',
                'observaciones' => 'sometimes|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Error de validación',
                    'errors' => $validator->errors()
                ], 422);
            }

            $admision->update($request->all());

            if ($request->has('nota_final')) {
                $admision->fecha_evaluacion = now();
                $admision->save();
            }

            return response()->json([
                'message' => 'Admisión actualizada',
                'admision' => $admision
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al actualizar admisión',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        try {
            $admision = Admision::find($id);

            if (!$admision) {
                return response()->json(['message' => 'Admisión no encontrada'], 404);
            }

            $admision->delete();

            return response()->json(['message' => 'Admisión eliminada']);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al eliminar admisión',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Inscribir un nuevo postulante (método personalizado)
     */
    public function inscribir(Request $request)
    {
        return $this->store($request);
    }

    /**
     * Obtener admisiones por estudiante
     */
    public function getByEstudiante($estudianteId)
    {
        try {
            $admisiones = Admision::where('estudiante_id', $estudianteId)
                ->with(['estudiante', 'estudiante.carrera'])
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json($admisiones);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al obtener admisiones del estudiante',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Evaluar un postulante
     */
    public function evaluar(Request $request, $id)
    {
        try {
            $validator = Validator::make($request->all(), [
                'nota_final' => 'required|numeric|min:0|max:20',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Error de validación',
                    'errors' => $validator->errors()
                ], 422);
            }

            $admision = Admision::find($id);

            if (!$admision) {
                return response()->json(['message' => 'Admisión no encontrada'], 404);
            }

            if ($admision->estado != 'inscrito') {
                return response()->json([
                    'message' => 'La admisión ya fue evaluada o no está en estado inscrito'
                ], 400);
            }

            $nota = $request->nota_final;
            $estado = $nota >= 11 ? 'evaluado' : 'no_ingresante';

            $admision->nota_final = $nota;
            $admision->estado = $estado;
            $admision->fecha_evaluacion = now();
            $admision->save();

            return response()->json([
                'message' => 'Evaluación registrada',
                'admision' => $admision,
                'resultado' => $estado == 'evaluado' ? 'Aprobado' : 'Desaprobado'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al evaluar',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Cambiar estado de la admisión
     */
    public function cambiarEstado(Request $request, $id)
    {
        try {
            $validator = Validator::make($request->all(), [
                'estado' => 'required|in:inscrito,evaluado,ingresante,no_ingresante',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Error de validación',
                    'errors' => $validator->errors()
                ], 422);
            }

            $admision = Admision::find($id);

            if (!$admision) {
                return response()->json(['message' => 'Admisión no encontrada'], 404);
            }

            $admision->estado = $request->estado;
            $admision->save();

            return response()->json([
                'message' => 'Estado actualizado',
                'admision' => $admision
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al actualizar estado',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}