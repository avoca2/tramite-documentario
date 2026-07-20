import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';

class MisTramitesScreen extends StatefulWidget {
  const MisTramitesScreen({super.key});

  @override
  State<MisTramitesScreen> createState() => _MisTramitesScreenState();
}

class _MisTramitesScreenState extends State<MisTramitesScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar trámites según el rol
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final roleProvider = Provider.of<RoleProvider>(context);
    final userEmail = authProvider.user?.email ?? '';
    final isEstudiante = roleProvider.rol == 'estudiante';
    final isSecretaria = roleProvider.rol == 'secretaria' || roleProvider.rol == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEstudiante ? 'Mis Trámites' : 'Todos los Trámites',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isEstudiante ? 'ESTUDIANTE' : 'SECRETARIA',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      isEstudiante ? Icons.assignment : Icons.list_alt,
                      color: AppColors.primary,
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEstudiante ? 'Mis Trámites' : 'Todos los Trámites',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEstudiante 
                              ? 'Aquí puedes ver el estado de tus trámites' 
                              : 'Aquí puedes ver y gestionar todos los trámites',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isEstudiante ? Colors.blue.shade100 : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isEstudiante ? 'Estudiante' : 'Secretaria',
                        style: TextStyle(
                          color: isEstudiante ? Colors.blue.shade700 : Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Lista de trámites (placeholder)
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(
                          Icons.assignment,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text('Trámite #${index + 1}'),
                      subtitle: Text(isEstudiante 
                        ? 'Estado: Pendiente' 
                        : 'Estudiante: Juan Pérez - Estado: Pendiente'),
                      trailing: isSecretaria 
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {},
                              ),
                            ],
                          )
                        : Chip(
                            label: Text(
                              'Pendiente',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: Colors.orange.shade100,
                          ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}