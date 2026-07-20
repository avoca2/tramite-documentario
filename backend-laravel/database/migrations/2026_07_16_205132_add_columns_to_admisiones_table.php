<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('admisiones', function (Blueprint $table) {
            $table->foreignId('estudiante_id')->constrained('estudiantes')->after('id');
            $table->string('modalidad')->default('ordinaria')->after('estudiante_id');
            $table->decimal('nota_final', 4, 2)->nullable()->after('modalidad');
            $table->string('estado')->default('inscrito')->after('nota_final');
            $table->string('lugar_procedencia')->nullable()->after('estado');
            $table->string('colegio_procedencia')->nullable()->after('lugar_procedencia');
            $table->text('observaciones')->nullable()->after('colegio_procedencia');
            $table->timestamp('fecha_inscripcion')->nullable()->after('observaciones');
            $table->timestamp('fecha_evaluacion')->nullable()->after('fecha_inscripcion');
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::table('admisiones', function (Blueprint $table) {
            $table->dropForeign(['estudiante_id']);
            $table->dropColumn([
                'estudiante_id', 'modalidad', 'nota_final', 'estado',
                'lugar_procedencia', 'colegio_procedencia', 'observaciones',
                'fecha_inscripcion', 'fecha_evaluacion', 'deleted_at'
            ]);
        });
    }
};
