<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('matriculas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('estudiante_id')->constrained('estudiantes')->onDelete('cascade');
            $table->string('periodo_academico', 20);
            $table->enum('tipo', ['ingresante', 'regular', 'extemporanea', 'reserva'])->default('regular');
            $table->enum('estado', ['activo', 'inactivo', 'reserva'])->default('activo');
            $table->string('codigo_matricula')->unique();
            $table->timestamp('fecha_matricula')->nullable();
            $table->decimal('monto_pagado', 10, 2)->nullable();
            $table->string('comprobante_pago', 50)->nullable();
            $table->text('observaciones')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('matriculas');
    }
};
