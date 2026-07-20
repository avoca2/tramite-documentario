<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('titulaciones', function (Blueprint $table) {
            $table->foreignId('estudiante_id')->constrained('estudiantes')->after('id');
            $table->enum('modalidad', ['innovacion_tecnologica', 'suficiencia_profesional'])->after('estudiante_id');
            $table->timestamp('fecha_examen')->nullable()->after('modalidad');
            $table->decimal('nota_examen', 4, 2)->nullable()->after('fecha_examen');
            $table->enum('estado', ['en_proceso', 'aprobado', 'desaprobado', 'titulado', 'reprogramado'])->default('en_proceso')->after('nota_examen');
            $table->string('numero_resolucion', 50)->nullable()->after('estado');
            $table->timestamp('fecha_titulacion')->nullable()->after('numero_resolucion');
            $table->string('numero_titulo', 50)->nullable()->after('fecha_titulacion');
            $table->string('proyecto_nombre', 255)->nullable()->after('numero_titulo');
            $table->text('proyecto_descripcion')->nullable()->after('proyecto_nombre');
            $table->timestamp('fecha_solicitud')->nullable()->after('proyecto_descripcion');
            $table->text('observaciones')->nullable()->after('fecha_solicitud');
            $table->json('documentos')->nullable()->after('observaciones');
        });
    }

    public function down(): void
    {
        Schema::table('titulaciones', function (Blueprint $table) {
            $table->dropForeign(['estudiante_id']);
            $table->dropColumn([
                'estudiante_id', 'modalidad', 'fecha_examen', 'nota_examen',
                'estado', 'numero_resolucion', 'fecha_titulacion', 'numero_titulo',
                'proyecto_nombre', 'proyecto_descripcion', 'fecha_solicitud',
                'observaciones', 'documentos'
            ]);
        });
    }
};
