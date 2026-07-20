<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create("seguimientos", function (Blueprint $table) {
            $table->id();
            $table->foreignId("tramite_id")->constrained()->onDelete("cascade");
            $table->string("estado_anterior", 50);
            $table->string("estado_nuevo", 50);
            $table->text("comentario")->nullable();
            $table->foreignId("usuario_id")->constrained("users");
            $table->string("ip", 45)->nullable();
            $table->timestamps();
            $table->index(["tramite_id", "created_at"]);
        });
    }
    public function down()
    {
        Schema::dropIfExists("seguimientos");
    }
};
