<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Matricula;
use App\Models\Estudiante;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class MatriculaController extends Controller
{
    public function index(Request $request)
    {
        try {
            $user = $request->user();
            $query = Matricula::with(['estudiante', 'estudiante.carrera']);
            
            // Si el usuario es estudiante, solo ver sus matrículas
            if ($user->rol === 'estudiante') {
                $estudiante = Estudiante::where('dni', $user->dni ?? '')->first();
                if ($estudiante) {
                    $query->where('estudiante_id', $estudiante->id);
                } else {
                    return response()->json([]);
                }
            }
            
            // Si es secretaria o admin, ver todas las matrículas
            $matriculas = $query->orderBy('created_at', 'desc')->get()
                ->map(function ($matricula) {
                    return [
                        'id' => $matricula->id,
                        'estudiante_id' => $matricula->estudiante_id,
                        'estudiante_nombre' => $matricula->estudiante ? $matricula->estudiante->nombre_completo : 'N/A',
                        'dni' => $matricula->estudiante ? $matricula->estudiante->dni : 'N/A',
                        'carrera' => $matricula->estudiante && $matricula->estudiante->carrera 
                            ? $matricula->estudiante->carrera->nombre 
                            : 'N/A',
                        'periodo_academico' => $matricula->periodo_academico,
                        'tipo' => $matricula->tipo,
                        'tipo_display' => $matricula->tipo_display,
                        'estado' => $matricula->estado,
                        'estado_display' => $matricula->estado_display,
                        'codigo_matricula' => $matricula->codigo_matricula,
                        'fecha_matricula' => $matricula->fecha_matricula,
                        'monto_pagado' => $matricula->monto_pagado,
                        'comprobante_pago' => $matricula->comprobante_pago,
                        'observaciones' => $matricula->observaciones,
                        'created_at' => $matricula->created_at,
                        'updated_at' => $matricula->updated_at,
                    ];
                });

            return response()->json($matriculas);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al obtener matrículas',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'dni' => 'required|string|size:8|exists:estudiantes,dni',
                'periodo_academico' => 'required|string|max:20',
                'tipo' => 'required|in:ingresante,regular,extemporanea,reserva',
                'monto_pagado' => 'required|numeric|min:0',
                'comprobante_pago' => 'nullable|string|max:50',
                'observaciones' => 'nullable|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Error de validación',
                    'errors' => $validator->errors()
                ], 422);
            }

            DB::beginTransaction();

            // Buscar el estudiante por DNI
            $estudiante = Estudiante::where('dni', $request->dni)->first();

            if (!$estudiante) {
                return response()->json([
                    'message' => 'Estudiante no encontrado con el DNI proporcionado'
                ], 404);
            }

            // Verificar si el estudiante tiene una matrícula activa en el mismo periodo
            $matriculaExistente = Matricula::where('estudiante_id', $estudiante->id)
                ->where('periodo_academico', $request->periodo_academico)
                ->whereIn('estado', ['activo', 'reserva'])
                ->first();

            if ($matriculaExistente) {
                return response()->json([
                    'message' => 'El estudiante ya tiene una matrícula activa para el periodo ' . $request->periodo_academico,
                    'matricula' => $matriculaExistente
                ], 409);
            }

            // Generar código de matrícula
            $year = date('Y');
            $count = Matricula::whereYear('created_at', $year)->count() + 1;
            $codigo_matricula = 'MAT-' . $year . '-' . str_pad($count, 4, '0', STR_PAD_LEFT);

            $matricula = Matricula::create([
                'estudiante_id' => $estudiante->id,
                'periodo_academico' => $request->periodo_academico,
                'tipo' => $request->tipo,
                'estado' => 'activo',
                'codigo_matricula' => $codigo_matricula,
                'fecha_matricula' => now(),
                'monto_pagado' => $request->monto_pagado,
                'comprobante_pago' => $request->comprobante_pago,
                'observaciones' => $request->observaciones,
            ]);

            DB::commit();

            return response()->json([
                'message' => 'Matrícula registrada exitosamente',
                'matricula' => $matricula->load('estudiante'),
                'codigo_matricula' => $codigo_matricula
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Error al registrar matrícula',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function show($id)
    {
        try {
            $matricula = Matricula::with(['estudiante', 'estudiante.carrera'])->find($id);

            if (!$matricula) {
                return response()->json(['message' => 'Matrícula no encontrada'], 404);
            }

            return response()->json([
                'id' => $matricula->id,
                'estudiante_id' => $matricula->estudiante_id,
                'estudiante_nombre' => $matricula->estudiante ? $matricula->estudiante->nombre_completo : 'N/A',
                'dni' => $matricula->estudiante ? $matricula->estudiante->dni : 'N/A',
                'carrera' => $matricula->estudiante && $matricula->estudiante->carrera 
                    ? $matricula->estudiante->carrera->nombre 
                    : 'N/A',
                'periodo_academico' => $matricula->periodo_academico,
                'tipo' => $matricula->tipo,
                'tipo_display' => $matricula->tipo_display,
                'estado' => $matricula->estado,
                'estado_display' => $matricula->estado_display,
                'codigo_matricula' => $matricula->codigo_matricula,
                'fecha_matricula' => $matricula->fecha_matricula,
                'monto_pagado' => $matricula->monto_pagado,
                'comprobante_pago' => $matricula->comprobante_pago,
                'observaciones' => $matricula->observaciones,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al obtener matrícula',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request, $id)
    {
        try {
            $matricula = Matricula::find($id);

            if (!$matricula) {
                return response()->json(['message' => 'Matrícula no encontrada'], 404);
            }

            $validator = Validator::make($request->all(), [
                'periodo_academico' => 'sometimes|string|max:20',
                'tipo' => 'sometimes|in:ingresante,regular,extemporanea,reserva',
                'estado' => 'sometimes|in:activo,inactivo,reserva',
                'monto_pagado' => 'sometimes|numeric|min:0',
                'observaciones' => 'nullable|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Error de validación',
                    'errors' => $validator->errors()
                ], 422);
            }

            $matricula->update($request->all());

            return response()->json([
                'message' => 'Matrícula actualizada',
                'matricula' => $matricula->load('estudiante')
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al actualizar matrícula',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id)
    {
        try {
            $matricula = Matricula::find($id);

            if (!$matricula) {
                return response()->json(['message' => 'Matrícula no encontrada'], 404);
            }

            $matricula->delete();

            return response()->json(['message' => 'Matrícula eliminada']);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al eliminar matrícula',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function matriculaRegular(Request $request)
    {
        return $this->store($request);
    }

    public function matriculaExtemporanea(Request $request)
    {
        $request->merge(['tipo' => 'extemporanea']);
        return $this->store($request);
    }

    public function getByEstudiante($estudianteId)
    {
        try {
            $matriculas = Matricula::where('estudiante_id', $estudianteId)
                ->with(['estudiante', 'estudiante.carrera'])
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json($matriculas);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al obtener matrículas del estudiante',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function getPeriodos()
    {
        try {
            $periodos = Matricula::select('periodo_academico')
                ->distinct()
                ->orderBy('periodo_academico', 'desc')
                ->pluck('periodo_academico');

            if ($periodos->isEmpty()) {
                // Si no hay periodos, devolver un periodo por defecto
                return response()->json(['2025-1']);
            }

            return response()->json($periodos);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al obtener periodos',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}