<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('estudiantes', function (Blueprint $table) {
            $table->string('dni', 8)->unique()->after('id');
        });
    }

    public function down(): void
    {
        Schema::table('estudiantes', function (Blueprint $table) {
            $table->dropColumn('dni');
        });
    }
};
