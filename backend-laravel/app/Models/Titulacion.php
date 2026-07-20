<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Titulacion extends Model
{
    use SoftDeletes;

    protected $table = 'titulaciones';

    protected $fillable = [
        'estudiante_id',
        'modalidad',
        'fecha_examen',
        'nota_examen',
        'estado',
        'numero_resolucion',
        'fecha_titulacion',
        'numero_titulo',
        'proyecto_nombre',
        'proyecto_descripcion',
        'fecha_solicitud',
        'observaciones',
        'documentos',
    ];

    protected $casts = [
        'fecha_examen' => 'datetime',
        'fecha_titulacion' => 'datetime',
        'fecha_solicitud' => 'datetime',
        'documentos' => 'array',
    ];

    public function estudiante()
    {
        return $this->belongsTo(Estudiante::class);
    }

    public function getModalidadDisplayAttribute()
    {
        $modalidades = [
            'innovacion_tecnologica' => 'Innovación Tecnológica',
            'suficiencia_profesional' => 'Suficiencia Profesional',
        ];
        return $modalidades[$this->modalidad] ?? $this->modalidad;
    }

    public function getEstadoDisplayAttribute()
    {
        $estados = [
            'en_proceso' => 'En Proceso',
            'aprobado' => 'Aprobado',
            'desaprobado' => 'Desaprobado',
            'titulado' => 'Titulado',
            'reprogramado' => 'Reprogramado',
        ];
        return $estados[$this->estado] ?? $this->estado;
    }

    public function getEstadoColorAttribute()
    {
        $colores = [
            'en_proceso' => 'orange',
            'aprobado' => 'green',
            'desaprobado' => 'red',
            'titulado' => 'blue',
            'reprogramado' => 'purple',
        ];
        return $colores[$this->estado] ?? 'grey';
    }
}
