import 'package:flutter/material.dart';
import '../utils/constants.dart';

class UltimosTramitesCard extends StatelessWidget {
  final List<dynamic> tramites;
  final VoidCallback? onVerMas;

  const UltimosTramitesCard({
    super.key,
    required this.tramites,
    this.onVerMas,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ultimos Tramites',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
                const Spacer(),
                if (tramites.isNotEmpty)
                  Text(
                    '${tramites.length} registros',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (tramites.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 32,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'No hay tramites registrados',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...tramites.take(5).map((tramite) => _buildTramiteItem(tramite)).toList(),
            if (tramites.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: GestureDetector(
                    onTap: onVerMas,
                    child: Text(
                      'Ver mas',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTramiteItem(dynamic tramite) {
    Color estadoColor;
    String estadoText;

    switch (tramite['estado']) {
      case 'pendiente':
      case 'inscrito':
        estadoColor = Colors.orange;
        estadoText = 'Pendiente';
        break;
      case 'en_proceso':
        estadoColor = Colors.blue;
        estadoText = 'En Proceso';
        break;
      case 'aprobado':
      case 'evaluado':
      case 'ingresante':
        estadoColor = Colors.green;
        estadoText = 'Aprobado';
        break;
      case 'rechazado':
      case 'no_ingresante':
        estadoColor = Colors.red;
        estadoText = 'Rechazado';
        break;
      default:
        estadoColor = Colors.grey;
        estadoText = tramite['estado'] ?? 'N/A';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(
              color: estadoColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tramite['estudiante'] ?? 'N/A',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey.shade900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      tramite['titulo'] ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tramite['dni'] ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: estadoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: estadoColor.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Text(
              estadoText,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: estadoColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}