<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create("tipos_documentos", function (Blueprint $table) {
            $table->id();
            $table->string("nombre", 100);
            $table->string("codigo", 50)->unique();
            $table->text("descripcion")->nullable();
            $table->boolean("obligatorio")->default(false);
            $table->string("formato_permitidos", 50)->default("pdf,jpg,png");
            $table->integer("tamano_maximo")->default(5120);
            $table->boolean("activo")->default(true);
            $table->timestamps();
        });
    }
    public function down()
    {
        Schema::dropIfExists("tipos_documentos");
    }
};
