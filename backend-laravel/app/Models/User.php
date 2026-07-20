<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'dni',
        'password',
        'rol',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * Verificar si el usuario es administrador
     */
    public function isAdmin(): bool
    {
        return $this->rol === 'admin';
    }

    /**
     * Verificar si el usuario es secretaria
     */
    public function isSecretaria(): bool
    {
        return $this->rol === 'secretaria';
    }

    /**
     * Verificar si el usuario es estudiante
     */
    public function isEstudiante(): bool
    {
        return $this->rol === 'estudiante';
    }

    /**
     * Verificar si el usuario es docente
     */
    public function isDocente(): bool
    {
        return $this->rol === 'docente';
    }

    /**
     * Verificar si el usuario es coordinador
     */
    public function isCoordinador(): bool
    {
        return $this->rol === 'coordinador';
    }

    /**
     * Verificar si el usuario es director
     */
    public function isDirector(): bool
    {
        return $this->rol === 'director';
    }

    /**
     * Obtener el nombre del rol en español
     */
    public function getRolDisplayAttribute(): string
    {
        $roles = [
            'admin' => 'Administrador',
            'secretaria' => 'Secretaria',
            'docente' => 'Docente',
            'coordinador' => 'Coordinador',
            'director' => 'Director',
            'estudiante' => 'Estudiante',
        ];
        return $roles[$this->rol] ?? $this->rol;
    }

    /**
     * Obtener el color del rol para la interfaz
     */
    public function getRolColorAttribute(): string
    {
        $colores = [
            'admin' => 'red',
            'secretaria' => 'blue',
            'docente' => 'green',
            'coordinador' => 'orange',
            'director' => 'purple',
            'estudiante' => 'teal',
        ];
        return $colores[$this->rol] ?? 'grey';
    }
}