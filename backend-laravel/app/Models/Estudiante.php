<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Estudiante extends Model
{
    use SoftDeletes;

    protected $table = 'estudiantes';

    protected $fillable = [
        'dni', 
        'nombres', 
        'apellido_paterno', 
        'apellido_materno',
        'fecha_nacimiento', 
        'celular', 
        'email', 
        'direccion',
        'carrera_id', 
        'codigo_estudiante', 
        'estado'
    ];

    public function carrera()
    {
        return $this->belongsTo(Carrera::class);
    }

    public function admisiones()
    {
        return $this->hasMany(Admision::class);
    }

    public function getNombreCompletoAttribute()
    {
        return "{$this->nombres} {$this->apellido_paterno} {$this->apellido_materno}";
    }
}