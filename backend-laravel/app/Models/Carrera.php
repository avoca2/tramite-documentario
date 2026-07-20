<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Carrera extends Model
{
    // Agregar esta línea
    protected $fillable = ['codigo', 'nombre', 'descripcion', 'activo'];
}
