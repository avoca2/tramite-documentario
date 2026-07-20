<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create("cursos", function (Blueprint $table) {
            $table->id();
            $table->foreignId("carrera_id")->constrained()->onDelete("cascade");
            $table->string("codigo", 20)->unique();
            $table->string("nombre", 200);
            $table->integer("creditos")->default(0);
            $table->integer("horas_teoria")->default(0);
            $table->integer("horas_practica")->default(0);
            $table->integer("ciclo")->default(1);
            $table->text("descripcion")->nullable();
            $table->boolean("activo")->default(true);
            $table->timestamps();
            $table->index(["carrera_id", "ciclo"]);
        });
        
        Schema::create("notas", function (Blueprint $table) {
            $table->id();
            $table->foreignId("estudiante_id")->constrained()->onDelete("cascade");
            $table->foreignId("curso_id")->constrained()->onDelete("cascade");
            $table->foreignId("periodo_academico_id")->constrained("periodos_academicos");
            $table->decimal("nota_parcial_1", 5, 2)->nullable();
            $table->decimal("nota_parcial_2", 5, 2)->nullable();
            $table->decimal("nota_examen", 5, 2)->nullable();
            $table->decimal("nota_final", 5, 2)->nullable();
            $table->string("estado", 20)->nullable();
            $table->string("tipo", 20)->default("regular");
            $table->text("observaciones")->nullable();
            $table->timestamps();
            $table->unique(["estudiante_id", "curso_id", "periodo_academico_id"], "notas_unique");
        });
    }
    public function down()
    {
        Schema::dropIfExists("notas");
        Schema::dropIfExists("cursos");
    }
};
