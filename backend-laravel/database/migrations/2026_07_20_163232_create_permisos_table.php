<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create("permisos", function (Blueprint $table) {
            $table->id();
            $table->string("nombre", 100)->unique();
            $table->string("grupo", 50);
            $table->string("descripcion", 255)->nullable();
            $table->timestamps();
            $table->index("grupo");
        });
        
        Schema::create("rol_permisos", function (Blueprint $table) {
            $table->id();
            $table->string("rol", 50);
            $table->foreignId("permiso_id")->constrained()->onDelete("cascade");
            $table->timestamps();
            $table->unique(["rol", "permiso_id"]);
        });
    }
    public function down()
    {
        Schema::dropIfExists("rol_permisos");
        Schema::dropIfExists("permisos");
    }
};
