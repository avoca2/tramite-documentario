<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Carrera;

class CarreraSeeder extends Seeder
{
    public function run(): void
    {
        $carreras = [
            ['codigo' => 'APS', 'nombre' => 'Arquitectura de Plataformas y Servicios Tecnológicos'],
            ['codigo' => 'LC', 'nombre' => 'Laboratorio Clínico'],
            ['codigo' => 'MPI', 'nombre' => 'Mecánica de Producción Industrial'],
            ['codigo' => 'EI', 'nombre' => 'Electricidad Industrial'],
        ];

        foreach ($carreras as $carrera) {
            Carrera::create($carrera);
        }
    }
}
