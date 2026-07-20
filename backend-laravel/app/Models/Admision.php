<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Admision extends Model
{
    use SoftDeletes;

    protected $table = 'admisiones'; // Forzar nombre de tabla

    protected $fillable = [
        'estudiante_id',
        'modalidad',
        'nota_final',
        'estado',
        'lugar_procedencia',
        'colegio_procedencia',
        'observaciones',
        'fecha_inscripcion',
        'fecha_evaluacion',
    ];

    protected $casts = [
        'fecha_inscripcion' => 'datetime',
        'fecha_evaluacion' => 'datetime',
    ];

    public function estudiante()
    {
        return $this->belongsTo(Estudiante::class);
    }
}