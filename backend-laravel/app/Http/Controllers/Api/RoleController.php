<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;

class RoleController extends Controller
{
    public function getUserRole(Request $request)
    {
        $user = $request->user();
        $rol = $user->rol ?? 'estudiante';
        
        return response()->json([
            'rol' => $rol,
            'permissions' => $this->getPermissions($rol)
        ]);
    }

    private function getPermissions($rol)
    {
        $permissions = [
            // ADMIN - Todos los permisos
            'admin' => [
                'dashboard' => true,
                'admision' => true,
                'matricula' => true,
                'convalidacion' => true,
                'traslado' => true,
                'certificacion' => true,
                'titulacion' => true,
                'evaluacion' => true,
                'ver_todos_tramites' => true,
                'gestionar_tramites' => true,
                'usuarios' => true,
                'reportes' => true,
                'configuracion' => true,
            ],
            // SECRETARIA - Puede ver y gestionar todos los trámites
            'secretaria' => [
                'dashboard' => true,
                'admision' => true,
                'matricula' => true,
                'convalidacion' => true,
                'traslado' => true,
                'certificacion' => true,
                'titulacion' => true,
                'evaluacion' => false,
                'ver_todos_tramites' => true,
                'gestionar_tramites' => true,
                'usuarios' => false,
                'reportes' => false,
                'configuracion' => false,
            ],
            // ESTUDIANTE - Solo puede solicitar y ver sus trámites
            'estudiante' => [
                'dashboard' => true,
                'admision' => false,
                'matricula' => true,
                'convalidacion' => true,
                'traslado' => true,
                'certificacion' => true,
                'titulacion' => true,
                'evaluacion' => false,
                'ver_todos_tramites' => false,
                'gestionar_tramites' => false,
                'usuarios' => false,
                'reportes' => false,
                'configuracion' => false,
            ],
        ];

        return $permissions[$rol] ?? $permissions['estudiante'];
    }
}