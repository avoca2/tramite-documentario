<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class ConsultaController extends Controller
{
    private $token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6Impvc2Vhdm9jYWRvMkBnbWFpbC5jb20ifQ.H7A6y0Qbw7-E1TflVHQOnefZsso6zkWd2Ycraq6SeNA';

    public function consultarDni($dni)
    {
        try {
            $response = Http::get("https://dniruc.apisperu.com/api/v1/dni/{$dni}?token={$this->token}");
            return response()->json($response->json());
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Error al consultar DNI',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function consultarRuc($ruc)
    {
        try {
            $response = Http::get("https://dniruc.apisperu.com/api/v1/ruc/{$ruc}?token={$this->token}");
            return response()->json($response->json());
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Error al consultar RUC',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
