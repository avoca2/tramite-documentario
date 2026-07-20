<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Código de Verificación</title>
</head>
<body style="font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px; margin: 0;">
    <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 10px; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
        <div style="text-align: center; border-bottom: 3px solid #CC0000; padding-bottom: 20px; margin-bottom: 20px;">
            <h1 style="color: #CC0000; margin: 0;">IESTP Jorge Desmaison Seminario</h1>
            <p style="color: #666; margin: 5px 0 0 0;">Sistema de Trámite Documentario</p>
        </div>
        
        <p style="color: #333; line-height: 1.6;">Hola,</p>
        <p style="color: #333; line-height: 1.6;">Has solicitado un código de verificación para registrarte en nuestro sistema.</p>
        <p style="color: #333; line-height: 1.6;">Tu código de verificación es:</p>
        
        <div style="text-align: center; font-size: 48px; font-weight: bold; color: #CC0000; letter-spacing: 8px; padding: 20px; background-color: #f8f8f8; border-radius: 8px; margin: 20px 0;">
            {{ $codigo }}
        </div>
        
        <p style="color: #333; line-height: 1.6;">Este código es válido por <strong>5 minutos</strong>.</p>
        <p style="color: #333; line-height: 1.6;">Si no solicitaste este código, por favor ignora este mensaje.</p>
        
        <div style="text-align: center; border-top: 1px solid #ddd; padding-top: 20px; margin-top: 20px; color: #999; font-size: 12px;">
            <p>© {{ date('Y') }} <strong style="color: #CC0000;">IESTP Jorge Desmaison Seminario</strong></p>
            <p>Este es un correo automático, por favor no responder.</p>
        </div>
    </div>
</body>
</html>
