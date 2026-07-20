<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create("notificaciones", function (Blueprint $table) {
            $table->id();
            $table->foreignId("usuario_id")->constrained("users")->onDelete("cascade");
            $table->string("titulo", 200);
            $table->text("contenido");
            $table->string("tipo", 50)->default("info");
            $table->string("icono", 50)->nullable();
            $table->string("link", 255)->nullable();
            $table->boolean("leida")->default(false);
            $table->timestamp("fecha_lectura")->nullable();
            $table->timestamps();
            $table->index(["usuario_id", "leida", "created_at"]);
        });
    }
    public function down()
    {
        Schema::dropIfExists("notificaciones");
    }
};
