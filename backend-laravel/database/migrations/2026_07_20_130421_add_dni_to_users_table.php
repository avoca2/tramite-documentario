<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table("users", function (Blueprint $table) {
            $table->string("dni", 8)->nullable()->after("email");
            $table->index("dni");
        });
    }

    public function down()
    {
        Schema::table("users", function (Blueprint $table) {
            $table->dropIndex(["dni"]);
            $table->dropColumn("dni");
        });
    }
};
