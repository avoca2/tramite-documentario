<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('convalidaciones', function (Blueprint $table) {
            $table->foreignId('estudiante_id')->constrained('estudiantes')->after('id');
            $table->enum('tipo', ['planes_estudio', 'unidades_competencia', 'efsrt'])->after('estudiante_id');
            $table->string('institucion_origen', 200)->after('tipo');
            $table->json('unidades_convalidadas')->nullable()->after('institucion_origen');
            $table->integer('total_creditos')->default(0)->after('unidades_convalidadas');
            $table->timestamp('fecha_solicitud')->nullable()->after('total_creditos');
            $table->enum('estado', ['pendiente', 'en_proceso', 'aprobado', 'rechazado'])->default('pendiente')->after('fecha_solicitud');
            $table->string('numero_resolucion', 50)->nullable()->after('estado');
            $table->timestamp('fecha_resolucion')->nullable()->after('numero_resolucion');
            $table->json('documentos')->nullable()->after('fecha_resolucion');
            $table->text('observaciones')->nullable()->after('documentos');
        });
    }

    public function down(): void
    {
        Schema::table('convalidaciones', function (Blueprint $table) {
            $table->dropForeign(['estudiante_id']);
            $table->dropColumn([
                'estudiante_id', 'tipo', 'institucion_origen', 'unidades_convalidadas',
                'total_creditos', 'fecha_solicitud', 'estado', 'numero_resolucion',
                'fecha_resolucion', 'documentos', 'observaciones'
            ]);
        });
    }
};
