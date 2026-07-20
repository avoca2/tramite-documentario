<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Tramite;

class TramiteController extends Controller
{
    public function index()
    {
        return Tramite::with('estudiante')->get();
    }

    public function store(Request $request)
    {
        $tramite = Tramite::create($request->all());
        return response()->json($tramite, 201);
    }

    public function show($id)
    {
        return Tramite::with('estudiante')->findOrFail($id);
    }

    public function update(Request $request, $id)
    {
        $tramite = Tramite::findOrFail($id);
        $tramite->update($request->all());
        return response()->json($tramite);
    }

    public function destroy($id)
    {
        Tramite::findOrFail($id)->delete();
        return response()->json(null, 204);
    }
}
