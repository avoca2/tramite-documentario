<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Admision;
use App\Models\Matricula;
use App\Models\Convalidacion;
use App\Models\Titulacion;
use App\Models\User;
use App\Models\Estudiante;

class DashboardController extends Controller
{
    public function getStats(Request $request)
    {
        try {
            // Contar registros reales
            $totalEstudiantes = Estudiante::count();
            $totalUsuarios = User::count();
            
            // Admisiones reales
            $admisionesPendientes = Admision::where('estado', 'inscrito')->count();
            $admisionesEvaluadas = Admision::where('estado', 'evaluado')->count();
            $admisionesIngresantes = Admision::where('estado', 'ingresante')->count();
            $totalAdmisiones = Admision::count();
            
            // Matrículas reales
            $matriculasActivas = Matricula::where('estado', 'activo')->count();
            $matriculasReserva = Matricula::where('estado', 'reserva')->count();
            $totalMatriculas = Matricula::count();
            
            // Convalidaciones reales
            $convalidacionesPendientes = Convalidacion::where('estado', 'pendiente')->count();
            $convalidacionesAprobadas = Convalidacion::where('estado', 'aprobado')->count();
            $convalidacionesRechazadas = Convalidacion::where('estado', 'rechazado')->count();
            $totalConvalidaciones = Convalidacion::count();
            
            // Titulaciones reales
            $titulacionesEnProceso = Titulacion::where('estado', 'en_proceso')->count();
            $titulacionesAprobadas = Titulacion::where('estado', 'aprobado')->count();
            $titulacionesTitulados = Titulacion::where('estado', 'titulado')->count();
            $totalTitulaciones = Titulacion::count();
            
            $stats = [
                'total_estudiantes' => $totalEstudiantes,
                'total_usuarios' => $totalUsuarios,
                'usuarios_activos' => $totalUsuarios,
                
                'admisiones_pendientes' => $admisionesPendientes,
                'admisiones_evaluadas' => $admisionesEvaluadas,
                'admisiones_ingresantes' => $admisionesIngresantes,
                'total_admisiones' => $totalAdmisiones,
                
                'matriculas_activas' => $matriculasActivas,
                'matriculas_reserva' => $matriculasReserva,
                'total_matriculas' => $totalMatriculas,
                
                'convalidaciones_pendientes' => $convalidacionesPendientes,
                'convalidaciones_aprobadas' => $convalidacionesAprobadas,
                'convalidaciones_rechazadas' => $convalidacionesRechazadas,
                'total_convalidaciones' => $totalConvalidaciones,
                
                'titulaciones_en_proceso' => $titulacionesEnProceso,
                'titulaciones_aprobadas' => $titulacionesAprobadas,
                'titulaciones_titulados' => $titulacionesTitulados,
                'total_titulaciones' => $totalTitulaciones,
            ];
            
            // Últimos 5 registros de cada tabla
            $ultimosTramites = [];
            
            // Admisiones recientes
            $admisiones = Admision::with('estudiante')
                ->orderBy('created_at', 'desc')
                ->limit(3)
                ->get();
                
            foreach ($admisiones as $item) {
                $ultimosTramites[] = [
                    'id' => $item->id,
                    'tipo' => 'admision',
                    'titulo' => 'Admisión',
                    'estudiante' => $item->estudiante ? $item->estudiante->nombre_completo : 'N/A',
                    'dni' => $item->estudiante ? $item->estudiante->dni : 'N/A',
                    'fecha' => $item->created_at,
                    'estado' => $item->estado,
                ];
            }
            
            // Matrículas recientes
            $matriculas = Matricula::with('estudiante')
                ->orderBy('created_at', 'desc')
                ->limit(3)
                ->get();
                
            foreach ($matriculas as $item) {
                $ultimosTramites[] = [
                    'id' => $item->id,
                    'tipo' => 'matricula',
                    'titulo' => 'Matrícula',
                    'estudiante' => $item->estudiante ? $item->estudiante->nombre_completo : 'N/A',
                    'dni' => $item->estudiante ? $item->estudiante->dni : 'N/A',
                    'fecha' => $item->created_at,
                    'estado' => $item->estado,
                ];
            }
            
            // Convalidaciones recientes
            $convalidaciones = Convalidacion::with('estudiante')
                ->orderBy('created_at', 'desc')
                ->limit(3)
                ->get();
                
            foreach ($convalidaciones as $item) {
                $ultimosTramites[] = [
                    'id' => $item->id,
                    'tipo' => 'convalidacion',
                    'titulo' => 'Convalidación',
                    'estudiante' => $item->estudiante ? $item->estudiante->nombre_completo : 'N/A',
                    'dni' => $item->estudiante ? $item->estudiante->dni : 'N/A',
                    'fecha' => $item->created_at,
                    'estado' => $item->estado,
                ];
            }
            
            // Titulaciones recientes
            $titulaciones = Titulacion::with('estudiante')
                ->orderBy('created_at', 'desc')
                ->limit(3)
                ->get();
                
            foreach ($titulaciones as $item) {
                $ultimosTramites[] = [
                    'id' => $item->id,
                    'tipo' => 'titulacion',
                    'titulo' => 'Titulación',
                    'estudiante' => $item->estudiante ? $item->estudiante->nombre_completo : 'N/A',
                    'dni' => $item->estudiante ? $item->estudiante->dni : 'N/A',
                    'fecha' => $item->created_at,
                    'estado' => $item->estado,
                ];
            }
            
            // Ordenar por fecha
            usort($ultimosTramites, function($a, $b) {
                return strtotime($b['fecha']) - strtotime($a['fecha']);
            });
            
            // Tomar solo los 8 primeros
            $ultimosTramites = array_slice($ultimosTramites, 0, 8);
            
            // Pendientes
            $pendientes = [
                'admisiones' => [],
                'convalidaciones' => [],
                'titulaciones' => [],
            ];
            
            // Admisiones pendientes
            $admisionesPendientesList = Admision::where('estado', 'inscrito')
                ->with('estudiante')
                ->orderBy('created_at', 'desc')
                ->limit(5)
                ->get();
                
            foreach ($admisionesPendientesList as $item) {
                $pendientes['admisiones'][] = [
                    'id' => $item->id,
                    'tipo' => 'admision',
                    'titulo' => 'Admisión',
                    'estudiante' => $item->estudiante ? $item->estudiante->nombre_completo : 'N/A',
                    'dni' => $item->estudiante ? $item->estudiante->dni : 'N/A',
                    'fecha' => $item->created_at,
                    'estado' => $item->estado,
                ];
            }
            
            // Convalidaciones pendientes
            $convalidacionesPendientesList = Convalidacion::where('estado', 'pendiente')
                ->with('estudiante')
                ->orderBy('created_at', 'desc')
                ->limit(5)
                ->get();
                
            foreach ($convalidacionesPendientesList as $item) {
                $pendientes['convalidaciones'][] = [
                    'id' => $item->id,
                    'tipo' => 'convalidacion',
                    'titulo' => 'Convalidación',
                    'estudiante' => $item->estudiante ? $item->estudiante->nombre_completo : 'N/A',
                    'dni' => $item->estudiante ? $item->estudiante->dni : 'N/A',
                    'fecha' => $item->created_at,
                    'estado' => $item->estado,
                ];
            }
            
            // Titulaciones en proceso
            $titulacionesPendientesList = Titulacion::where('estado', 'en_proceso')
                ->with('estudiante')
                ->orderBy('created_at', 'desc')
                ->limit(5)
                ->get();
                
            foreach ($titulacionesPendientesList as $item) {
                $pendientes['titulaciones'][] = [
                    'id' => $item->id,
                    'tipo' => 'titulacion',
                    'titulo' => 'Titulación',
                    'estudiante' => $item->estudiante ? $item->estudiante->nombre_completo : 'N/A',
                    'dni' => $item->estudiante ? $item->estudiante->dni : 'N/A',
                    'fecha' => $item->created_at,
                    'estado' => $item->estado,
                ];
            }
            
            // Usuarios conectados
            $usuariosConectados = [
                [
                    'id' => 1,
                    'name' => 'Administrador',
                    'email' => 'admin@iestp.edu.pe',
                    'rol' => 'admin',
                    'last_activity' => now()->subMinutes(2),
                ],
            ];
            
            return response()->json([
                'stats' => $stats,
                'ultimos_tramites' => $ultimosTramites,
                'pendientes' => $pendientes,
                'usuarios_conectados' => $usuariosConectados,
                'total_pendientes' => $admisionesPendientes + $convalidacionesPendientes + $titulacionesEnProceso,
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al obtener estadísticas',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}