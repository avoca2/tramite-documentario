<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class VerificacionEmail extends Model
{
protected $table = "verificacion_emails";

protected $fillable = [
"email",
"codigo",
"expira_at",
"usado",
];

protected $casts = [
"expira_at" => "datetime",
"usado" => "boolean",
];

public function esValido(): bool
{
return !$this->usado && $this->expira_at > now();
}
}
