<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use App\Models\VerificacionEmail;
use App\Models\Estudiante;
use Illuminate\Support\Facades\Mail;
use App\Mail\CodigoVerificacionMail;

class AuthController extends Controller
{
    // ============ LOGIN ============
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Credenciales inválidas'
            ], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
        ]);
    }

    // ============ ENVIAR CÓDIGO DE VERIFICACIÓN ============
    public function enviarCodigo(Request $request)
    {
        try {
            $request->validate([
                'email' => 'required|email',
            ]);

            // Verificar si el email ya está registrado
            if (User::where('email', $request->email)->exists()) {
                return response()->json([
                    'message' => 'El email ya está registrado'
                ], 409);
            }

            // Generar código de 6 dígitos
            $codigo = str_pad(random_int(100000, 999999), 6, '0', STR_PAD_LEFT);

            // Guardar en la base de datos
            VerificacionEmail::where('email', $request->email)->delete();
            
            VerificacionEmail::create([
                'email' => $request->email,
                'codigo' => $codigo,
                'expira_at' => now()->addMinutes(5),
                'usado' => false,
            ]);

            // Enviar email real
            try {
                Mail::to($request->email)->send(new CodigoVerificacionMail($codigo));
                return response()->json([
                    'message' => 'Código enviado exitosamente a tu correo',
                ]);
            } catch (\Exception $mailError) {
                return response()->json([
                    'message' => 'Error al enviar email, pero el código fue generado',
                    'codigo' => $codigo,
                    'error' => $mailError->getMessage()
                ], 500);
            }

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al enviar el código',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // ============ VERIFICAR CÓDIGO ============
    public function verificarCodigo(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'codigo' => 'required|string|size:6',
        ]);

        $verificacion = VerificacionEmail::where('email', $request->email)
            ->where('codigo', $request->codigo)
            ->first();

        if (!$verificacion || !$verificacion->esValido()) {
            return response()->json([
                'message' => 'Código inválido o expirado'
            ], 400);
        }

        // Marcar como usado
        $verificacion->usado = true;
        $verificacion->save();

        return response()->json([
            'message' => 'Código verificado exitosamente'
        ]);
    }

    // ============ REGISTRO CON VERIFICACIÓN Y DNI ============
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'dni' => 'required|string|size:8',
            'password' => 'required|string|min:8',
            'codigo' => 'required|string|size:6',
        ]);

        // Verificar si el DNI ya está registrado en algún usuario
        $userExistente = User::where('dni', $request->dni)->first();
        if ($userExistente) {
            return response()->json([
                'message' => 'El DNI ya está registrado en el sistema'
            ], 409);
        }

        // Verificar si el DNI ya está registrado como estudiante
        $estudianteExistente = Estudiante::where('dni', $request->dni)->first();

        // Verificar el código
        $verificacion = VerificacionEmail::where('email', $request->email)
            ->where('codigo', $request->codigo)
            ->where('usado', true)
            ->first();

        if (!$verificacion) {
            return response()->json([
                'message' => 'Código no verificado o inválido'
            ], 400);
        }

        DB::beginTransaction();

        try {
            // Crear usuario
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'dni' => $request->dni,
                'password' => Hash::make($request->password),
                'rol' => 'estudiante', // Por defecto estudiante
            ]);

            // Si el estudiante no existe en la tabla estudiantes, crearlo
            if (!$estudianteExistente) {
                // Si el DNI no está registrado, buscar en RENIEC
                try {
                    $reniecData = $this->consultarReniec($request->dni);
                    Estudiante::create([
                        'dni' => $request->dni,
                        'nombres' => $reniecData['nombres'] ?? 'N/A',
                        'apellido_paterno' => $reniecData['apellidoPaterno'] ?? 'N/A',
                        'apellido_materno' => $reniecData['apellidoMaterno'] ?? 'N/A',
                        'celular' => '000000000',
                        'email' => $request->email,
                        'estado' => 'activo',
                        'codigo_estudiante' => 'EST-' . date('Y') . '-' . str_pad(Estudiante::count() + 1, 4, '0', STR_PAD_LEFT),
                    ]);
                } catch (\Exception $e) {
                    // Si falla la consulta RENIEC, crear estudiante con datos básicos
                    Estudiante::create([
                        'dni' => $request->dni,
                        'nombres' => $request->name,
                        'apellido_paterno' => 'N/A',
                        'apellido_materno' => 'N/A',
                        'celular' => '000000000',
                        'email' => $request->email,
                        'estado' => 'activo',
                        'codigo_estudiante' => 'EST-' . date('Y') . '-' . str_pad(Estudiante::count() + 1, 4, '0', STR_PAD_LEFT),
                    ]);
                }
            } else {
                // Si el estudiante ya existe, actualizar su email
                $estudianteExistente->email = $request->email;
                $estudianteExistente->save();
            }

            // Limpiar verificaciones usadas
            VerificacionEmail::where('email', $request->email)->delete();

            DB::commit();

            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'message' => 'Usuario registrado exitosamente',
                'user' => $user,
                'token' => $token,
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Error al registrar usuario',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // ============ CONSULTAR RENIEC ============
    private function consultarReniec($dni)
    {
        try {
            $token = env('API_PERU_TOKEN');
            $response = \Illuminate\Support\Facades\Http::get("https://dniruc.apisperu.com/api/v1/dni/{$dni}?token={$token}");
            return $response->json();
        } catch (\Exception $e) {
            return [
                'nombres' => 'N/A',
                'apellidoPaterno' => 'N/A',
                'apellidoMaterno' => 'N/A'
            ];
        }
    }

    // ============ LOGOUT ============
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Sesión cerrada correctamente']);
    }

    // ============ OBTENER USUARIO ACTUAL ============
    public function user(Request $request)
    {
        return response()->json($request->user());
    }
}