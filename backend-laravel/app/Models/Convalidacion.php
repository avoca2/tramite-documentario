<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Convalidacion extends Model
{
    use SoftDeletes;

    protected $table = 'convalidaciones';

    protected $fillable = [
        'estudiante_id',
        'tipo',
        'institucion_origen',
        'unidades_convalidadas',
        'total_creditos',
        'fecha_solicitud',
        'estado',
        'numero_resolucion',
        'fecha_resolucion',
        'documentos',
        'observaciones',
    ];

    protected $casts = [
        'fecha_solicitud' => 'datetime',
        'fecha_resolucion' => 'datetime',
        'unidades_convalidadas' => 'array',
        'documentos' => 'array',
    ];

    public function estudiante()
    {
        return $this->belongsTo(Estudiante::class);
    }

    public function getTipoDisplayAttribute()
    {
        $tipos = [
            'planes_estudio' => 'Entre Planes de Estudio',
            'unidades_competencia' => 'Unidades de Competencia',
            'efsrt' => 'EFSRT (Experiencias Formativas)',
        ];
        return $tipos[$this->tipo] ?? $this->tipo;
    }

    public function getEstadoDisplayAttribute()
    {
        $estados = [
            'pendiente' => 'Pendiente',
            'en_proceso' => 'En Proceso',
            'aprobado' => 'Aprobado',
            'rechazado' => 'Rechazado',
        ];
        return $estados[$this->estado] ?? $this->estado;
    }

    public function getEstadoColorAttribute()
    {
        $colores = [
            'pendiente' => 'orange',
            'en_proceso' => 'blue',
            'aprobado' => 'green',
            'rechazado' => 'red',
        ];
        return $colores[$this->estado] ?? 'grey';
    }
}
