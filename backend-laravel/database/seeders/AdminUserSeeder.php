<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        // Admin
        if (!User::where('email', 'admin@iestp.edu.pe')->exists()) {
            User::create([
                'name' => 'Administrador',
                'email' => 'admin@iestp.edu.pe',
                'password' => Hash::make('admin123'),
                'rol' => 'admin',
            ]);
        }
        
        // Secretaria
        if (!User::where('email', 'secretaria@iestp.edu.pe')->exists()) {
            User::create([
                'name' => 'Secretaria General',
                'email' => 'secretaria@iestp.edu.pe',
                'password' => Hash::make('admin123'),
                'rol' => 'secretaria',
            ]);
        }
        
        // Estudiante de ejemplo
        if (!User::where('email', 'estudiante@iestp.edu.pe')->exists()) {
            User::create([
                'name' => 'Estudiante Ejemplo',
                'email' => 'estudiante@iestp.edu.pe',
                'password' => Hash::make('admin123'),
                'rol' => 'estudiante',
            ]);
        }
    }
}
