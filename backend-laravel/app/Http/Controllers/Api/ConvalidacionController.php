<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Convalidacion;
use App\Models\Estudiante;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConvalidacionController extends Controller
{
    public function index()
    {
        try {
            $convalidaciones = Convalidacion::with(['estudiante', 'estudiante.carrera'])
                ->orderBy('created_at', 'desc')
                ->get()
                ->map(function ($convalidacion) {
                    return [
                        'id' => $convalidacion->id,
                        'estudiante_id' => $convalidacion->estudiante_id,
                        'estudiante_nombre' => $convalidacion->estudiante ? $convalidacion->estudiante->nombre_completo : 'N/A',
                        'dni' => $convalidacion->estudiante ? $convalidacion->estudiante->dni : 'N/A',
                        'carrera' => $convalidacion->estudiante && $convalidacion->estudiante->carrena 
                            ? $convalidacion->estudiante->carrera->nombre 
                            : 'N/A',
                        'tipo' => $convalidacion->tipo,
                        'tipo_display' => $convalidacion->tipo_display,
                        'institucion_origen' => $convalidacion->institucion_origen,
                        'unidades_convalidadas' => $convalidacion->unidades_convalidadas,
                        'total_creditos' => $convalidacion->total_creditos,
                        'fecha_solicitud' => $convalidacion->fecha_solicitud,
                        'estado' => $convalidacion->estado,
                        'estado_display' => $convalidacion->estado_display,
                        'estado_color' => $convalidacion->estado_color,
                        'numero_resolucion' => $convalidacion->numero_resolucion,
                        'fecha_resolucion' => $convalidacion->fecha_resolucion,
                        'observaciones' => $convalidacion->observaciones,
                        'created_at' => $convalidacion->created_at,
                        'updated_at' => $convalidacion->updated_at,
                    ];
                });

            return response()->json($convalidaciones);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al obtener convalidaciones',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'dni' => 'required|string|size:8|exists:estudiantes,dni',
                'tipo' => 'required|in:planes_estudio,unidades_competencia,efsrt',
                'institucion_origen' => 'required|string|max:200',
                'unidades_convalidadas' => 'nullable|array',
                'total_creditos' => 'nullable|integer|min:0',
                'observaciones' => 'nullable|string',
                'documentos' => 'nullable|array',
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

            // Verificar si ya tiene una convalidación en proceso
            $convalidacionExistente = Convalidacion::where('estudiante_id', $estudiante->id)
                ->whereIn('estado', ['pendiente', 'en_proceso'])
                ->first();

            if ($convalidacionExistente) {
                return response()->json([
                    'message' => 'El estudiante ya tiene una convalidación en proceso',
                    'convalidacion' => $convalidacionExistente
                ], 409);
            }

            // Generar número de resolución automático
            $year = date('Y');
            $count = Convalidacion::whereYear('created_at', $year)->count() + 1;
            $numero_resolucion = 'RES-CONV-' . $year . '-' . str_pad($count, 4, '0', STR_PAD_LEFT);

            $convalidacion = Convalidacion::create([
                'estudiante_id' => $estudiante->id,
                'tipo' => $request->tipo,
                'institucion_origen' => $request->institucion_origen,
                'unidades_convalidadas' => $request->unidades_convalidadas ?? [],
                'total_creditos' => $request->total_creditos ?? 0,
                'fecha_solicitud' => now(),
                'estado' => 'pendiente',
                'numero_resolucion' => $numero_resolucion,
                'observaciones' => $request->observaciones,
                'documentos' => $request->documentos ?? [],
            ]);

            DB::commit();

            return response()->json([
                'message' => 'Solicitud de convalidación registrada exitosamente',
                'convalidacion' => $convalidacion->load('estudiante'),
                'numero_resolucion' => $numero_resolucion
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Error al registrar convalidación',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function show($id)
    {
        try {
            $convalidacion = Convalidacion::with(['estudiante', 'estudiante.carrera'])->find($id);

            if (!$convalidacion) {
                return response()->json(['message' => 'Convalidación no encontrada'], 404);
            }

            return response()->json([
                'id' => $convalidacion->id,
                'estudiante_id' => $convalidacion->estudiante_id,
                'estudiante_nombre' => $convalidacion->estudiante ? $convalidacion->estudiante->nombre_completo : 'N/A',
                'dni' => $convalidacion->estudiante ? $convalidacion->estudiante->dni : 'N/A',
                'carrera' => $convalidacion->estudiante && $convalidacion->estudiante->carrera 
                    ? $convalidacion->estudiante->carrera->nombre 
                    : 'N/A',
                'tipo' => $convalidacion->tipo,
                'tipo_display' => $convalidacion->tipo_display,
                'institucion_origen' => $convalidacion->institucion_origen,
                'unidades_convalidadas' => $convalidacion->unidades_convalidadas,
                'total_creditos' => $convalidacion->total_creditos,
                'fecha_solicitud' => $convalidacion->fecha_solicitud,
                'estado' => $convalidacion->estado,
                'estado_display' => $convalidacion->estado_display,
                'numero_resolucion' => $convalidacion->numero_resolucion,
                'fecha_resolucion' => $convalidacion->fecha_resolucion,
                'observaciones' => $convalidacion->observaciones,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al obtener convalidación',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request, $id)
    {
        try {
            $convalidacion = Convalidacion::find($id);

            if (!$convalidacion) {
                return response()->json(['message' => 'Convalidación no encontrada'], 404);
            }

            $validator = Validator::make($request->all(), [
                'tipo' => 'sometimes|in:planes_estudio,unidades_competencia,efsrt',
                'estado' => 'sometimes|in:pendiente,en_proceso,aprobado,rechazado',
                'observaciones' => 'nullable|string',
                'unidades_convalidadas' => 'nullable|array',
                'total_creditos' => 'nullable|integer|min:0',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Error de validación',
                    'errors' => $validator->errors()
                ], 422);
            }

            if ($request->has('estado') && in_array($request->estado, ['aprobado', 'rechazado'])) {
                $convalidacion->fecha_resolucion = now();
            }

            $convalidacion->update($request->all());

            return response()->json([
                'message' => 'Convalidación actualizada',
                'convalidacion' => $convalidacion->load('estudiante')
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al actualizar convalidación',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id)
    {
        try {
            $convalidacion = Convalidacion::find($id);

            if (!$convalidacion) {
                return response()->json(['message' => 'Convalidación no encontrada'], 404);
            }

            if ($convalidacion->estado == 'aprobado') {
                return response()->json([
                    'message' => 'No se puede eliminar una convalidación aprobada'
                ], 400);
            }

            $convalidacion->delete();

            return response()->json(['message' => 'Convalidación eliminada']);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al eliminar convalidación',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // Métodos adicionales
    public function solicitar(Request $request)
    {
        return $this->store($request);
    }

    public function getByEstudiante($estudianteId)
    {
        try {
            $convalidaciones = Convalidacion::where('estudiante_id', $estudianteId)
                ->with(['estudiante', 'estudiante.carrera'])
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json($convalidaciones);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al obtener convalidaciones del estudiante',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function aprobar(Request $request, $id)
    {
        try {
            $convalidacion = Convalidacion::find($id);

            if (!$convalidacion) {
                return response()->json(['message' => 'Convalidación no encontrada'], 404);
            }

            if ($convalidacion->estado != 'pendiente' && $convalidacion->estado != 'en_proceso') {
                return response()->json([
                    'message' => 'La convalidación ya fue procesada'
                ], 400);
            }

            $convalidacion->estado = 'aprobado';
            $convalidacion->fecha_resolucion = now();
            $convalidacion->save();

            return response()->json([
                'message' => 'Convalidación aprobada',
                'convalidacion' => $convalidacion->load('estudiante')
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al aprobar convalidación',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function rechazar(Request $request, $id)
    {
        try {
            $convalidacion = Convalidacion::find($id);

            if (!$convalidacion) {
                return response()->json(['message' => 'Convalidación no encontrada'], 404);
            }

            if ($convalidacion->estado != 'pendiente' && $convalidacion->estado != 'en_proceso') {
                return response()->json([
                    'message' => 'La convalidación ya fue procesada'
                ], 400);
            }

            $convalidacion->estado = 'rechazado';
            $convalidacion->fecha_resolucion = now();
            $convalidacion->save();

            return response()->json([
                'message' => 'Convalidación rechazada',
                'convalidacion' => $convalidacion->load('estudiante')
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al rechazar convalidación',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
