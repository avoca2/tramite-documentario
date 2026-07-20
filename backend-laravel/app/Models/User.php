<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        "name",
        "email",
        "dni",
        "password",
        "rol",
        "activo",
    ];

    protected $hidden = [
        "password",
        "remember_token",
    ];

    protected function casts(): array
    {
        return [
            "email_verified_at" => "datetime",
            "password" => "hashed",
        ];
    }

    public function isAdmin(): bool
    {
        return $this->rol === "admin";
    }

    public function isSecretaria(): bool
    {
        return $this->rol === "secretaria";
    }

    public function isEstudiante(): bool
    {
        return $this->rol === "estudiante";
    }

    public function isDocente(): bool
    {
        return $this->rol === "docente";
    }

    public function isCoordinador(): bool
    {
        return $this->rol === "coordinador";
    }

    public function isDirector(): bool
    {
        return $this->rol === "director";
    }

    public function getRolDisplayAttribute(): string
    {
        $roles = [
            "admin" => "Administrador",
            "secretaria" => "Secretaria",
            "docente" => "Docente",
            "coordinador" => "Coordinador",
            "director" => "Director",
            "estudiante" => "Estudiante",
        ];
        return $roles[$this->rol] ?? $this->rol;
    }

    public function estudiante()
    {
        return $this->hasOne(Estudiante::class);
    }
}
