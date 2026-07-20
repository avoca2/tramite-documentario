import "package:flutter/material.dart";
import "../services/notificacion_service.dart";
import "../models/notificacion.dart";
import "../utils/constants.dart";

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({Key? key}) : super(key: key);

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  final NotificacionService _notificacionService = NotificacionService();
  List<Notificacion> _notificaciones = [];
  bool _isLoading = true;
  int _noLeidas = 0;

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    setState(() => _isLoading = true);
    try {
      final notificaciones = await _notificacionService.getNotificaciones();
      final noLeidas = await _notificacionService.getContadorNoLeidas();
      setState(() {
        _notificaciones = notificaciones;
        _noLeidas = noLeidas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar notificaciones: $e")),
      );
    }
  }

  Future<void> _marcarComoLeida(int id) async {
    try {
      await _notificacionService.marcarComoLeida(id);
      _cargarNotificaciones();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _marcarTodasComoLeidas() async {
    try {
      await _notificacionService.marcarTodasComoLeidas();
      _cargarNotificaciones();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todas las notificaciones marcadas como leídas")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Notificaciones"),
            const SizedBox(width: 8),
            if (_noLeidas > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _noLeidas.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_noLeidas > 0)
            IconButton(
              onPressed: _marcarTodasComoLeidas,
              icon: const Icon(Icons.done_all),
              tooltip: "Marcar todas como leídas",
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notificaciones.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "No tienes notificaciones",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notificaciones.length,
                  itemBuilder: (context, index) {
                    final notificacion = _notificaciones[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: notificacion.leida ? Colors.white : Colors.blue[50],
                      child: ListTile(
                        leading: _getIcon(notificacion.tipo),
                        title: Text(
                          notificacion.titulo,
                          style: TextStyle(
                            fontWeight: notificacion.leida ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notificacion.contenido),
                            Text(
                              _formatDate(notificacion.createdAt),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: notificacion.leida
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : IconButton(
                                icon: const Icon(Icons.circle, color: Colors.blue, size: 12),
                                onPressed: () => _marcarComoLeida(notificacion.id),
                              ),
                        onTap: () {
                          if (!notificacion.leida) {
                            _marcarComoLeida(notificacion.id);
                          }
                          if (notificacion.link != null) {
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Icon _getIcon(String tipo) {
    switch (tipo) {
      case "success":
        return const Icon(Icons.check_circle, color: Colors.green);
      case "warning":
        return const Icon(Icons.warning, color: Colors.orange);
      case "error":
        return const Icon(Icons.error, color: Colors.red);
      default:
        return const Icon(Icons.info, color: Colors.blue);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return "${date.day}/${date.month}/${date.year}";
    } else if (difference.inDays > 1) {
      return "Hace ${difference.inDays} días";
    } else if (difference.inDays == 1) {
      return "Ayer";
    } else if (difference.inHours > 1) {
      return "Hace ${difference.inHours} horas";
    } else if (difference.inHours >= 1) {
      return "Hace 1 hora";
    } else if (difference.inMinutes > 1) {
      return "Hace ${difference.inMinutes} minutos";
    } else {
      return "Ahora";
    }
  }
}
