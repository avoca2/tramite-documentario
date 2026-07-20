<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('estudiantes', function (Blueprint $table) {
            $table->string('nombres')->after('dni');
            $table->string('apellido_paterno')->after('nombres');
            $table->string('apellido_materno')->after('apellido_paterno');
            $table->date('fecha_nacimiento')->nullable()->after('apellido_materno');
            $table->string('celular')->after('fecha_nacimiento');
            $table->string('email')->after('celular');
            $table->string('direccion')->nullable()->after('email');
            $table->foreignId('carrera_id')->nullable()->constrained('carreras')->after('direccion');
            $table->string('codigo_estudiante')->unique()->nullable()->after('carrera_id');
            $table->string('estado')->default('activo')->after('codigo_estudiante');
        });
    }

    public function down(): void
    {
        Schema::table('estudiantes', function (Blueprint $table) {
            $table->dropForeign(['carrera_id']);
            $table->dropColumn([
                'nombres', 'apellido_paterno', 'apellido_materno',
                'fecha_nacimiento', 'celular', 'email', 'direccion',
                'carrera_id', 'codigo_estudiante', 'estado'
            ]);
        });
    }
};
