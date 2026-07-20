<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Matricula extends Model
{
    use SoftDeletes;

    protected $table = 'matriculas';

    protected $fillable = [
        'estudiante_id',
        'periodo_academico',
        'tipo',
        'estado',
        'codigo_matricula',
        'fecha_matricula',
        'monto_pagado',
        'comprobante_pago',
        'observaciones',
    ];

    protected $casts = [
        'fecha_matricula' => 'datetime',
        'monto_pagado' => 'decimal:2',
    ];

    public function estudiante()
    {
        return $this->belongsTo(Estudiante::class);
    }

    public function getTipoDisplayAttribute()
    {
        $tipos = [
            'ingresante' => 'Ingresante',
            'regular' => 'Regular',
            'extemporanea' => 'Extemporanea',
            'reserva' => 'Reserva',
        ];
        return $tipos[$this->tipo] ?? $this->tipo;
    }

    public function getEstadoDisplayAttribute()
    {
        $estados = [
            'activo' => 'Activo',
            'inactivo' => 'Inactivo',
            'reserva' => 'En Reserva',
        ];
        return $estados[$this->estado] ?? $this->estado;
    }
}
