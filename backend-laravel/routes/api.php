<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ConsultaController;
use App\Http\Controllers\Api\AdmisionController;
use App\Http\Controllers\Api\MatriculaController;
use App\Http\Controllers\Api\ConvalidacionController;
use App\Http\Controllers\Api\TitulacionController;
use App\Http\Controllers\Api\RoleController;
use App\Http\Controllers\Api\DashboardController;

// ============ RUTAS PÚBLICAS ============
Route::post('/login', [AuthController::class, 'login']);

// Registro con verificación por email
Route::post('/enviar-codigo', [AuthController::class, 'enviarCodigo']);
Route::post('/verificar-codigo', [AuthController::class, 'verificarCodigo']);
Route::post('/register', [AuthController::class, 'register']);

// Consultas públicas (SUNAT/RENIEC)
Route::get('/consulta/dni/{dni}', [ConsultaController::class, 'consultarDni']);
Route::get('/consulta/ruc/{ruc}', [ConsultaController::class, 'consultarRuc']);

// ============ RUTAS PROTEGIDAS ============
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
    Route::get('/user-role', [RoleController::class, 'getUserRole']);
    
    // ============ DASHBOARD ============
    Route::get('/dashboard/stats', [DashboardController::class, 'getStats']);
    
    // ============ ADMISION ============
    Route::get('/admision', [AdmisionController::class, 'index']);
    Route::post('/admision', [AdmisionController::class, 'store']);
    Route::get('/admision/{id}', [AdmisionController::class, 'show']);
    Route::put('/admision/{id}', [AdmisionController::class, 'update']);
    Route::delete('/admision/{id}', [AdmisionController::class, 'destroy']);
    
    Route::post('/admision/inscribir', [AdmisionController::class, 'inscribir']);
    Route::get('/admision/estudiante/{estudianteId}', [AdmisionController::class, 'getByEstudiante']);
    Route::put('/admision/evaluar/{id}', [AdmisionController::class, 'evaluar']);
    Route::put('/admision/estado/{id}', [AdmisionController::class, 'cambiarEstado']);
    
    // ============ MATRICULA ============
    Route::get('/matricula', [MatriculaController::class, 'index']);
    Route::post('/matricula', [MatriculaController::class, 'store']);
    Route::get('/matricula/{id}', [MatriculaController::class, 'show']);
    Route::put('/matricula/{id}', [MatriculaController::class, 'update']);
    Route::delete('/matricula/{id}', [MatriculaController::class, 'destroy']);
    
    Route::post('/matricula/regular', [MatriculaController::class, 'matriculaRegular']);
    Route::post('/matricula/extemporanea', [MatriculaController::class, 'matriculaExtemporanea']);
    Route::get('/matricula/estudiante/{estudianteId}', [MatriculaController::class, 'getByEstudiante']);
    Route::get('/matricula/periodos', [MatriculaController::class, 'getPeriodos']);
    
    // ============ CONVALIDACION ============
    Route::get('/convalidacion', [ConvalidacionController::class, 'index']);
    Route::post('/convalidacion', [ConvalidacionController::class, 'store']);
    Route::get('/convalidacion/{id}', [ConvalidacionController::class, 'show']);
    Route::put('/convalidacion/{id}', [ConvalidacionController::class, 'update']);
    Route::delete('/convalidacion/{id}', [ConvalidacionController::class, 'destroy']);
    
    Route::post('/convalidacion/solicitar', [ConvalidacionController::class, 'solicitar']);
    Route::get('/convalidacion/estudiante/{estudianteId}', [ConvalidacionController::class, 'getByEstudiante']);
    Route::put('/convalidacion/aprobar/{id}', [ConvalidacionController::class, 'aprobar']);
    Route::put('/convalidacion/rechazar/{id}', [ConvalidacionController::class, 'rechazar']);
    
    // ============ TITULACION ============
    Route::get('/titulacion', [TitulacionController::class, 'index']);
    Route::post('/titulacion', [TitulacionController::class, 'store']);
    Route::get('/titulacion/{id}', [TitulacionController::class, 'show']);
    Route::put('/titulacion/{id}', [TitulacionController::class, 'update']);
    Route::delete('/titulacion/{id}', [TitulacionController::class, 'destroy']);
    
    Route::post('/titulacion/solicitar', [TitulacionController::class, 'solicitar']);
    Route::put('/titulacion/reprogramar/{id}', [TitulacionController::class, 'reprogramar']);
    Route::put('/titulacion/evaluar/{id}', [TitulacionController::class, 'evaluar']);
    Route::put('/titulacion/otorgar/{id}', [TitulacionController::class, 'otorgarTitulo']);
    
    // ============ TRASLADO ============
    // Route::get('/traslado', [TrasladoController::class, 'index']);
    // Route::post('/traslado', [TrasladoController::class, 'store']);
    // Route::get('/traslado/{id}', [TrasladoController::class, 'show']);
    // Route::put('/traslado/{id}', [TrasladoController::class, 'update']);
    // Route::delete('/traslado/{id}', [TrasladoController::class, 'destroy']);
    
    // Route::post('/traslado/interno', [TrasladoController::class, 'trasladoInterno']);
    // Route::post('/traslado/externo', [TrasladoController::class, 'trasladoExterno']);
    
    // ============ CERTIFICACION ============
    // Route::get('/certificacion', [CertificacionController::class, 'index']);
    // Route::post('/certificacion', [CertificacionController::class, 'store']);
    // Route::get('/certificacion/{id}', [CertificacionController::class, 'show']);
    // Route::put('/certificacion/{id}', [CertificacionController::class, 'update']);
    // Route::delete('/certificacion/{id}', [CertificacionController::class, 'destroy']);
    
    // Route::post('/certificacion/solicitar', [CertificacionController::class, 'solicitar']);
    
    // ============ EVALUACION ============
    // Route::get('/evaluacion', [EvaluacionController::class, 'index']);
    // Route::post('/evaluacion', [EvaluacionController::class, 'store']);
    // Route::get('/evaluacion/{id}', [EvaluacionController::class, 'show']);
    // Route::put('/evaluacion/{id}', [EvaluacionController::class, 'update']);
    // Route::delete('/evaluacion/{id}', [EvaluacionController::class, 'destroy']);
    
    // Route::get('/evaluacion/estudiante/{estudianteId}', [EvaluacionController::class, 'getByEstudiante']);
    // Route::post('/evaluacion/recuperacion', [EvaluacionController::class, 'recuperacion']);
});