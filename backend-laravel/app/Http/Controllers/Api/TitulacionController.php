<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Titulacion;
use App\Models\Estudiante;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class TitulacionController extends Controller
{
    public function index(Request $request)
    {
        try {
            $user = $request->user();
            $query = Titulacion::with(['estudiante', 'estudiante.carrera']);

            // Si es estudiante, solo ver sus titulaciones
            if ($user->rol === 'estudiante') {
                $estudiante = Estudiante::where('dni', $user->dni ?? '')->first();
                if ($estudiante) {
                    $query->where('estudiante_id', $estudiante->id);
                } else {
                    return response()->json([]);
                }
            }

            $titulaciones = $query->orderBy('created_at', 'desc')->get()
                ->map(function ($titulacion) {
                    return [
                        'id' => $titulacion->id,
                        'estudiante_id' => $titulacion->estudiante_id,
                        'estudiante_nombre' => $titulacion->estudiante ? $titulacion->estudiante->nombre_completo : 'N/A',
                        'dni' => $titulacion->estudiante ? $titulacion->estudiante->dni : 'N/A',
                        'carrera' => $titulacion->estudiante && $titulacion->estudiante->carrera 
                            ? $titulacion->estudiante->carrera->nombre 
                            : 'N/A',
                        'modalidad' => $titulacion->modalidad,
                        'modalidad_display' => $titulacion->modalidad_display,
                        'fecha_examen' => $titulacion->fecha_examen,
                        'nota_examen' => $titulacion->nota_examen,
                        'estado' => $titulacion->estado,
                        'estado_display' => $titulacion->estado_display,
                        'estado_color' => $titulacion->estado_color,
                        'numero_resolucion' => $titulacion->numero_resolucion,
                        'fecha_titulacion' => $titulacion->fecha_titulacion,
                        'numero_titulo' => $titulacion->numero_titulo,
                        'proyecto_nombre' => $titulacion->proyecto_nombre,
                        'fecha_solicitud' => $titulacion->fecha_solicitud,
                        'observaciones' => $titulacion->observaciones,
                        'created_at' => $titulacion->created_at,
                        'updated_at' => $titulacion->updated_at,
                    ];
                });

            return response()->json($titulaciones);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al obtener titulaciones',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'dni' => 'required|string|size:8|exists:estudiantes,dni',
                'modalidad' => 'required|in:innovacion_tecnologica,suficiencia_profesional',
                'proyecto_nombre' => 'nullable|string|max:255',
                'proyecto_descripcion' => 'nullable|string',
                'fecha_examen' => 'nullable|date',
                'observaciones' => 'nullable|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Error de validación',
                    'errors' => $validator->errors()
                ], 422);
            }

            DB::beginTransaction();

            $estudiante = Estudiante::where('dni', $request->dni)->first();

            if (!$estudiante) {
                return response()->json([
                    'message' => 'Estudiante no encontrado'
                ], 404);
            }

            // Verificar si ya tiene una titulación en proceso
            $titulacionExistente = Titulacion::where('estudiante_id', $estudiante->id)
                ->whereIn('estado', ['en_proceso', 'aprobado'])
                ->first();

            if ($titulacionExistente) {
                return response()->json([
                    'message' => 'El estudiante ya tiene un proceso de titulación activo',
                    'titulacion' => $titulacionExistente
                ], 409);
            }

            // Generar número de resolución automático
            $year = date('Y');
            $count = Titulacion::whereYear('created_at', $year)->count() + 1;
            $numero_resolucion = 'RES-TIT-' . $year . '-' . str_pad($count, 4, '0', STR_PAD_LEFT);

            $titulacion = Titulacion::create([
                'estudiante_id' => $estudiante->id,
                'modalidad' => $request->modalidad,
                'estado' => 'en_proceso',
                'numero_resolucion' => $numero_resolucion,
                'fecha_solicitud' => now(),
                'proyecto_nombre' => $request->proyecto_nombre,
                'proyecto_descripcion' => $request->proyecto_descripcion,
                'fecha_examen' => $request->fecha_examen,
                'observaciones' => $request->observaciones,
                'documentos' => $request->documentos ?? [],
            ]);

            DB::commit();

            return response()->json([
                'message' => 'Solicitud de titulación registrada exitosamente',
                'titulacion' => $titulacion->load('estudiante'),
                'numero_resolucion' => $numero_resolucion
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Error al registrar titulación',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function show($id)
    {
        try {
            $titulacion = Titulacion::with(['estudiante', 'estudiante.carrera'])->find($id);

            if (!$titulacion) {
                return response()->json(['message' => 'Titulación no encontrada'], 404);
            }

            return response()->json([
                'id' => $titulacion->id,
                'estudiante_id' => $titulacion->estudiante_id,
                'estudiante_nombre' => $titulacion->estudiante ? $titulacion->estudiante->nombre_completo : 'N/A',
                'dni' => $titulacion->estudiante ? $titulacion->estudiante->dni : 'N/A',
                'carrera' => $titulacion->estudiante && $titulacion->estudiante->carrera 
                    ? $titulacion->estudiante->carrera->nombre 
                    : 'N/A',
                'modalidad' => $titulacion->modalidad,
                'modalidad_display' => $titulacion->modalidad_display,
                'fecha_examen' => $titulacion->fecha_examen,
                'nota_examen' => $titulacion->nota_examen,
                'estado' => $titulacion->estado,
                'estado_display' => $titulacion->estado_display,
                'numero_resolucion' => $titulacion->numero_resolucion,
                'fecha_titulacion' => $titulacion->fecha_titulacion,
                'numero_titulo' => $titulacion->numero_titulo,
                'proyecto_nombre' => $titulacion->proyecto_nombre,
                'fecha_solicitud' => $titulacion->fecha_solicitud,
                'observaciones' => $titulacion->observaciones,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al obtener titulación',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request, $id)
    {
        try {
            $titulacion = Titulacion::find($id);

            if (!$titulacion) {
                return response()->json(['message' => 'Titulación no encontrada'], 404);
            }

            $validator = Validator::make($request->all(), [
                'modalidad' => 'sometimes|in:innovacion_tecnologica,suficiencia_profesional',
                'estado' => 'sometimes|in:en_proceso,aprobado,desaprobado,titulado,reprogramado',
                'nota_examen' => 'nullable|numeric|min:0|max:20',
                'numero_titulo' => 'nullable|string|max:50',
                'fecha_examen' => 'nullable|date',
                'fecha_titulacion' => 'nullable|date',
                'observaciones' => 'nullable|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Error de validación',
                    'errors' => $validator->errors()
                ], 422);
            }

            $data = $request->all();

            // Si el estado cambia a aprobado o titulado, actualizar fechas
            if (isset($data['estado']) && in_array($data['estado'], ['aprobado', 'titulado'])) {
                if (!isset($data['fecha_titulacion'])) {
                    $data['fecha_titulacion'] = now();
                }
            }

            $titulacion->update($data);

            return response()->json([
                'message' => 'Titulación actualizada',
                'titulacion' => $titulacion->load('estudiante')
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al actualizar titulación',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id)
    {
        try {
            $titulacion = Titulacion::find($id);

            if (!$titulacion) {
                return response()->json(['message' => 'Titulación no encontrada'], 404);
            }

            if ($titulacion->estado == 'titulado') {
                return response()->json([
                    'message' => 'No se puede eliminar una titulación ya otorgada'
                ], 400);
            }

            $titulacion->delete();

            return response()->json(['message' => 'Titulación eliminada']);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al eliminar titulación',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // Métodos adicionales
    public function solicitar(Request $request)
    {
        return $this->store($request);
    }

    public function reprogramar(Request $request, $id)
    {
        try {
            $titulacion = Titulacion::find($id);

            if (!$titulacion) {
                return response()->json(['message' => 'Titulación no encontrada'], 404);
            }

            $validator = Validator::make($request->all(), [
                'fecha_examen' => 'required|date|after:today',
                'observaciones' => 'nullable|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Error de validación',
                    'errors' => $validator->errors()
                ], 422);
            }

            $titulacion->fecha_examen = $request->fecha_examen;
            $titulacion->estado = 'reprogramado';
            $titulacion->observaciones = ($titulacion->observaciones ? $titulacion->observaciones . "\n" : '') 
                . 'Reprogramado para: ' . $request->fecha_examen;
            $titulacion->save();

            return response()->json([
                'message' => 'Examen reprogramado exitosamente',
                'titulacion' => $titulacion->load('estudiante')
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al reprogramar examen',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function evaluar(Request $request, $id)
    {
        try {
            $validator = Validator::make($request->all(), [
                'nota_examen' => 'required|numeric|min:0|max:20',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Error de validación',
                    'errors' => $validator->errors()
                ], 422);
            }

            $titulacion = Titulacion::find($id);

            if (!$titulacion) {
                return response()->json(['message' => 'Titulación no encontrada'], 404);
            }

            if ($titulacion->estado != 'en_proceso') {
                return response()->json([
                    'message' => 'La titulación no está en proceso'
                ], 400);
            }

            $nota = $request->nota_examen;
            $estado = $nota >= 13 ? 'aprobado' : 'desaprobado';

            $titulacion->nota_examen = $nota;
            $titulacion->estado = $estado;
            
            if ($estado == 'aprobado') {
                $titulacion->fecha_titulacion = now();
                // Generar número de título
                $year = date('Y');
                $count = Titulacion::whereNotNull('numero_titulo')->count() + 1;
                $titulacion->numero_titulo = 'TIT-' . $year . '-' . str_pad($count, 6, '0', STR_PAD_LEFT);
            }
            
            $titulacion->save();

            return response()->json([
                'message' => 'Evaluación registrada',
                'titulacion' => $titulacion->load('estudiante'),
                'resultado' => $estado == 'aprobado' ? 'Aprobado' : 'Desaprobado'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al evaluar',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function otorgarTitulo($id)
    {
        try {
            $titulacion = Titulacion::find($id);

            if (!$titulacion) {
                return response()->json(['message' => 'Titulación no encontrada'], 404);
            }

            if ($titulacion->estado != 'aprobado') {
                return response()->json([
                    'message' => 'La titulación debe estar aprobada para otorgar el título'
                ], 400);
            }

            $titulacion->estado = 'titulado';
            $titulacion->fecha_titulacion = now();
            
            if (!$titulacion->numero_titulo) {
                $year = date('Y');
                $count = Titulacion::whereNotNull('numero_titulo')->count() + 1;
                $titulacion->numero_titulo = 'TIT-' . $year . '-' . str_pad($count, 6, '0', STR_PAD_LEFT);
            }
            
            $titulacion->save();

            return response()->json([
                'message' => 'Título otorgado exitosamente',
                'titulacion' => $titulacion->load('estudiante')
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al otorgar título',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
