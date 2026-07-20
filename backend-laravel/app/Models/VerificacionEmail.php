<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class VerificacionEmail extends Model
{
    protected $table = "verificacion_emails";

    protected $fillable = [
        "email",
        "codigo",
        "expira_at"
    ];

    protected $casts = [
        "expira_at" => "datetime"
    ];
}
