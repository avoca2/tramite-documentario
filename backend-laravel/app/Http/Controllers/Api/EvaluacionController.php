<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class EvaluacionController extends Controller
{
    public function index()
    {
        return response()->json(['message' => 'Lista de Evaluaciones']);
    }

    public function store(Request $request)
    {
        return response()->json(['message' => 'Evaluacion creada'], 201);
    }

    public function show($id)
    {
        return response()->json(['message' => 'Mostrando Evaluacion ' . $id]);
    }

    public function update(Request $request, $id)
    {
        return response()->json(['message' => 'Evaluacion actualizada']);
    }

    public function destroy($id)
    {
        return response()->json(['message' => 'Evaluacion eliminada'], 204);
    }
}
