<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Estudiante extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'codigo',
        'nombres',
        'apellido_paterno',
        'apellido_materno',
        'dni',
        'email',
        'celular',
        'telefono',
        'direccion',
        'carrera_id',
        'user_id',
        'estado',
        'fecha_nacimiento',
        'genero'
    ];

    protected $casts = [
        'fecha_nacimiento' => 'date',
    ];

    public function carrera()
    {
        return $this->belongsTo(Carrera::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function matriculas()
    {
        return $this->hasMany(Matricula::class);
    }

    public function admisiones()
    {
        return $this->hasMany(Admision::class);
    }

    public function convalidaciones()
    {
        return $this->hasMany(Convalidacion::class);
    }

    public function titulaciones()
    {
        return $this->hasMany(Titulacion::class);
    }

    public function evaluaciones()
    {
        return $this->hasMany(Evaluacion::class);
    }

    public function getNombreCompletoAttribute()
    {
        return $this->nombres . ' ' . $this->apellido_paterno . ' ' . $this->apellido_materno;
    }
}
