<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create("configuraciones", function (Blueprint $table) {
            $table->id();
            $table->string("grupo", 50);
            $table->string("clave", 100);
            $table->text("valor");
            $table->string("tipo", 20)->default("string");
            $table->string("descripcion", 255)->nullable();
            $table->boolean("editable")->default(true);
            $table->timestamps();
            $table->unique(["grupo", "clave"]);
            $table->index("grupo");
        });
    }
    public function down()
    {
        Schema::dropIfExists("configuraciones");
    }
};
