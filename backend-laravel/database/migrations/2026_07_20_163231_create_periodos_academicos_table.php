<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create("periodos_academicos", function (Blueprint $table) {
            $table->id();
            $table->string("nombre", 50);
            $table->string("codigo", 20)->unique();
            $table->date("fecha_inicio");
            $table->date("fecha_fin");
            $table->date("fecha_limite_inscripcion")->nullable();
            $table->date("fecha_limite_pago")->nullable();
            $table->boolean("activo")->default(false);
            $table->boolean("actual")->default(false);
            $table->timestamps();
        });
    }
    public function down()
    {
        Schema::dropIfExists("periodos_academicos");
    }
};
