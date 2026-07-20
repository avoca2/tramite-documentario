<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            "email" => "required|string|email|max:255|unique:users",
            "dni" => "required|string|size:8",
            "codigo" => "required|string|size:6",
            "password" => "required|string|min:6|confirmed",
        ];
    }

    public function messages()
    {
        return [
            "email.required" => "El email es requerido",
            "email.unique" => "El email ya está registrado",
            "dni.required" => "El DNI es requerido",
            "dni.size" => "El DNI debe tener 8 dígitos",
            "codigo.required" => "El código de verificación es requerido",
            "codigo.size" => "El código debe tener 6 dígitos",
            "password.required" => "La contraseña es requerida",
            "password.min" => "La contraseña debe tener al menos 6 caracteres",
            "password.confirmed" => "Las contraseñas no coinciden",
        ];
    }
}
