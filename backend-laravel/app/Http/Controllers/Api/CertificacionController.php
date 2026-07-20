<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class CertificacionController extends Controller
{
    public function index()
    {
        return response()->json(['message' => 'Lista de Certificaciones']);
    }

    public function store(Request $request)
    {
        return response()->json(['message' => 'Certificacion creada'], 201);
    }

    public function show($id)
    {
        return response()->json(['message' => 'Mostrando Certificacion ' . $id]);
    }

    public function update(Request $request, $id)
    {
        return response()->json(['message' => 'Certificacion actualizada']);
    }

    public function destroy($id)
    {
        return response()->json(['message' => 'Certificacion eliminada'], 204);
    }
}
