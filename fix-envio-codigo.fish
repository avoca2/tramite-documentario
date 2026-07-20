#!/usr/bin/env fish

echo "=== CORRIGIENDO ENVÍO DE CÓDIGO ==="

cd ~/proyectos/tramite-documentario/backend-laravel

echo "1. Creando modelo VerificacionEmail..."

echo '<?php

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
}' > app/Models/VerificacionEmail.php

echo "2. Creando migración..."
php artisan make:migration create_verificacion_emails_table

echo "3. Editando migración..."

set MIGRATION_FILE (ls -t database/migrations/ | grep create_verificacion_emails_table | head -1)

echo '<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
public function up(): void
{
Schema::create("verificacion_emails", function (Blueprint $table) {
$table->id();
$table->string("email", 100);
$table->string("codigo", 6);
$table->timestamp("expira_at");
$table->boolean("usado")->default(false);
$table->timestamps();

$table->index("email");
$table->index("codigo");
});
}

public function down(): void
{
Schema::dropIfExists("verificacion_emails");
}
};' > "database/migrations/$MIGRATION_FILE"

echo "4. Ejecutando migración..."
php artisan migrate

echo "5. Reconstruyendo autoload..."
composer dump-autoload

echo "6. Probando API..."
curl -X POST "http://localhost:8000/api/enviar-codigo" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com"}'

echo ""
echo "=== FIN ==="
