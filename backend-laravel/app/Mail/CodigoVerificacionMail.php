<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class CodigoVerificacionMail extends Mailable
{
    use Queueable, SerializesModels;

    public $codigo;

    public function __construct($codigo)
    {
        $this->codigo = $codigo;
    }

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Código de Verificación - IESTP Jorge Desmaison Seminario',
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.codigo-verificacion',
        );
    }
}
