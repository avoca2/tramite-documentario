<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create("documentos", function (Blueprint $table) {
            $table->id();
            $table->foreignId("estudiante_id")->constrained()->onDelete("cascade");
            $table->foreignId("tipo_documento_id")->constrained("tipos_documentos");
            $table->string("nombre_archivo", 255);
            $table->string("ruta", 500);
            $table->string("mime_type", 100);
            $table->integer("tamano")->unsigned();
            $table->string("hash", 64)->nullable();
            $table->string("estado", 20)->default("pendiente");
            $table->text("observaciones")->nullable();
            $table->timestamp("fecha_verificacion")->nullable();
            $table->foreignId("verificado_por")->nullable()->constrained("users");
            $table->timestamps();
            $table->softDeletes();
            $table->index(["estudiante_id", "tipo_documento_id"]);
        });
    }
    public function down()
    {
        Schema::dropIfExists("documentos");
    }
};
