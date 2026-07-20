<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create("verificacion_emails", function (Blueprint $table) {
            $table->id();
            $table->string("email", 255);
            $table->string("codigo", 10);
            $table->timestamp("expira_at");
            $table->timestamps();
            $table->index("email");
            $table->index("codigo");
        });
    }

    public function down()
    {
        Schema::dropIfExists("verificacion_emails");
    }
};
