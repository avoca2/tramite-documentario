<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class TrasladoController extends Controller
{
    public function index()
    {
        return response()->json(['message' => 'Lista de Traslados']);
    }

    public function store(Request $request)
    {
        return response()->json(['message' => 'Traslado creado'], 201);
    }

    public function show($id)
    {
        return response()->json(['message' => 'Mostrando Traslado ' . $id]);
    }

    public function update(Request $request, $id)
    {
        return response()->json(['message' => 'Traslado actualizado']);
    }

    public function destroy($id)
    {
        return response()->json(['message' => 'Traslado eliminado'], 204);
    }
}
