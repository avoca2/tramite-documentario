import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../tramites/admision_screen.dart';
import '../tramites/matricula_screen.dart';
import '../tramites/convalidacion_screen.dart';
import '../tramites/titulacion_screen.dart';

// ============ UTILIDAD DE NOTIFICACIONES ============
class AppNotifications {
  static void showToast(String message, {ToastGravity gravity = ToastGravity.BOTTOM}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.grey.shade800,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  static void showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  static void showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  static void showSuccessSnackbar(BuildContext context, String title, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: ContentType.success,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showErrorSnackbar(BuildContext context, String title, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: ContentType.failure,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // NUEVO MÉTODO AGREGADO - showInfoSnackbar
  static void showInfoSnackbar(BuildContext context, String title, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: ContentType.help,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

// ============ SHIMMER WIDGET ============
class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({super.key, required this.child, this.isLoading = true});

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: child,
    );
  }
}

// ============ BADGE ICON ============
class BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color? color;
  final VoidCallback? onTap;

  const BadgeIcon({super.key, required this.icon, required this.count, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return IconButton(
        icon: Icon(icon, color: color ?? Colors.grey.shade700),
        onPressed: onTap,
      );
    }
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: -4, end: -4),
      badgeAnimation: const badges.BadgeAnimation.slide(
        toAnimate: true,
        animationDuration: Duration(milliseconds: 300),
      ),
      badgeStyle: badges.BadgeStyle(
        badgeColor: Colors.red,
        shape: badges.BadgeShape.circle,
        // badgeGap: 4, // ELIMINADO - Ya no es soportado en badges 3.2.0
        padding: const EdgeInsets.all(4),
      ),
      child: IconButton(
        icon: Icon(icon, color: color ?? Colors.grey.shade700),
        onPressed: onTap,
      ),
      badgeContent: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ============ SHIMMER STATS CARD ============
class ShimmerStatsCard extends StatelessWidget {
  const ShimmerStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 28, height: 28, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Container(width: 40, height: 28, color: Colors.grey.shade300),
          const SizedBox(height: 4),
          Container(width: 80, height: 14, color: Colors.grey.shade300),
        ],
      ),
    );
  }
}

// ============ STAT CARD ============
class StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const StatCard({super.key, required this.title, required this.subtitle, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

// ============ ACTION BUTTON ============
class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ActionButton(this.label, this.icon, this.color, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.black87, size: 18),
      label: Text(label, style: const TextStyle(color: Colors.black87)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// ============ ADMIN DASHBOARD SCREEN ============
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _dniController = TextEditingController();
  Map<String, dynamic>? _dniResult;
  bool _loadingDni = false;
  String? _dniError;
  
  Map<String, dynamic>? _dashboardStats;
  bool _loadingStats = false;
  List<dynamic> _ultimosTramites = [];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      _apiService.setToken(authProvider.token!);
    }
    _cargarDashboardStats();
  }

  Future<void> _cargarDashboardStats() async {
    setState(() {
      _loadingStats = true;
    });

    try {
      final data = await _apiService.getDashboardStats();
      setState(() {
        _dashboardStats = data;
        _ultimosTramites = data['ultimos_tramites'] ?? [];
        _loadingStats = false;
      });
    } catch (e) {
      setState(() {
        _loadingStats = false;
      });
    }
  }

  Future<void> _consultarDni() async {
    final dni = _dniController.text.trim();
    if (dni.length < 8) {
      setState(() {
        _dniError = 'Ingrese un DNI valido de 8 digitos';
      });
      return;
    }

    setState(() {
      _loadingDni = true;
      _dniError = null;
    });

    try {
      final data = await _apiService.consultarDni(dni);
      setState(() {
        _dniResult = data;
        _loadingDni = false;
      });
      AppNotifications.showSuccessToast('DNI encontrado correctamente');
    } catch (e) {
      setState(() {
        _dniError = 'Error al consultar DNI: $e';
        _loadingDni = false;
      });
      AppNotifications.showErrorToast('Error al consultar DNI');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final stats = _dashboardStats?['stats'];
    final totalEstudiantes = stats?['total_estudiantes'] ?? 0;
    final admisionesPendientes = stats?['admisiones_pendientes'] ?? 0;
    final matriculasActivas = stats?['matriculas_activas'] ?? 0;
    final convalidacionesPendientes = stats?['convalidaciones_pendientes'] ?? 0;
    final totalUsuarios = stats?['total_usuarios'] ?? 0;
    final totalPendientes = _dashboardStats?['total_pendientes'] ?? 0;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(context),
          // Contenido principal
          Expanded(
            child: _loadingStats
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bienvenida
                        _buildWelcomeSection(authProvider),
                        const SizedBox(height: 32),

                        // Estadísticas
                        Row(
                          children: [
                            const Text(
                              'Estadisticas generales',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            BadgeIcon(
                              icon: Icons.notifications,
                              count: totalPendientes,
                              onTap: () {
                                AppNotifications.showInfoSnackbar(
                                  context,
                                  'Notificaciones',
                                  'Tienes $totalPendientes pendientes de atencion',
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _cargarDashboardStats,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.8,
                          children: [
                            StatCard(
                              title: '$totalEstudiantes',
                              subtitle: 'Estudiantes\nTotal registrados',
                              color: Colors.blue,
                              icon: Icons.school,
                            ),
                            StatCard(
                              title: '$admisionesPendientes',
                              subtitle: 'Admisiones\nPendientes',
                              color: Colors.purple,
                              icon: Icons.assignment,
                            ),
                            StatCard(
                              title: '$matriculasActivas',
                              subtitle: 'Matriculas\nActivas',
                              color: Colors.green,
                              icon: Icons.how_to_reg,
                            ),
                            StatCard(
                              title: '$convalidacionesPendientes',
                              subtitle: 'Convalidaciones\nEn proceso',
                              color: Colors.orange,
                              icon: Icons.swap_horiz,
                            ),
                            StatCard(
                              title: '$totalUsuarios',
                              subtitle: 'Usuarios\nRegistrados',
                              color: Colors.indigo,
                              icon: Icons.people,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Últimos trámites y gráfico
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Últimos trámites
                            Expanded(
                              flex: 2,
                              child: _buildUltimosTramitesCard(),
                            ),
                            const SizedBox(width: 24),
                            // Gráfico de torta
                            Expanded(
                              child: _buildPieChartCard(stats),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Consultas rápidas y Acciones
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildConsultaDniCard(),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildAccionesRapidasCard(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.grey[100],
      child: Column(
        children: [
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFFE31C2B)),
            title: const Text('Inicio'),
            tileColor: Colors.white,
          ),
          const Divider(),
          _buildSidebarItem(Icons.assignment, 'Tramites', () {}),
          _buildSidebarItem(Icons.school, 'Admision', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdmisionScreen()));
          }),
          _buildSidebarItem(Icons.how_to_reg, 'Matricula', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MatriculaScreen()));
          }),
          _buildSidebarItem(Icons.verified, 'Convalidacion', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ConvalidacionScreen()));
          }),
          _buildSidebarItem(Icons.military_tech, 'Titulacion', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TitulacionScreen()));
          }),
          const Divider(),
          _buildSidebarItem(Icons.people, 'Estudiantes', () {}),
          _buildSidebarItem(Icons.person, 'Docentes', () {}),
          _buildSidebarItem(Icons.group, 'Usuarios', () {}),
          const Divider(),
          _buildSidebarItem(Icons.analytics, 'Estadisticas', () {}),
          _buildSidebarItem(Icons.description, 'Reportes', () {}),
          _buildSidebarItem(Icons.download, 'Exportar', () {}),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar sesion'),
            onTap: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final roleProvider = Provider.of<RoleProvider>(context, listen: false);
              authProvider.logout();
              roleProvider.clear();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title, style: TextStyle(color: Colors.grey.shade800)),
      onTap: onTap,
    );
  }

  Widget _buildWelcomeSection(AuthProvider authProvider) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFFE31C2B),
          child: Text(
            authProvider.user?.name?.substring(0, 1).toUpperCase() ?? 'A',
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, ${authProvider.user?.name ?? "Administrador"}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Gestiona y supervisa los tramites academicos de la institucion.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUltimosTramitesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ultimos tramites',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_ultimosTramites.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text('No hay tramites registrados'),
                ),
              )
            else
              ..._ultimosTramites.take(4).map((tramite) => _buildTramiteRow(tramite)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                AppNotifications.showInfoSnackbar(
                  context,
                  'Informacion',
                  'Ver todos los tramites',
                );
              },
              child: const Text('Ver todos los tramites →'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTramiteRow(dynamic tramite) {
    String estadoText;
    Color estadoColor;

    switch (tramite['estado']) {
      case 'pendiente':
      case 'inscrito':
        estadoText = 'Pendiente';
        estadoColor = Colors.orange;
        break;
      case 'activo':
        estadoText = 'Activo';
        estadoColor = Colors.green;
        break;
      case 'en_proceso':
        estadoText = 'En Proceso';
        estadoColor = Colors.blue;
        break;
      default:
        estadoText = tramite['estado'] ?? 'N/A';
        estadoColor = Colors.grey;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Text(
          tramite['estudiante']?.substring(0, 1) ?? 'N',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ),
      title: Text(
        tramite['estudiante'] ?? 'N/A',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text('${tramite['titulo'] ?? ''} - ${tramite['dni'] ?? ''}'),
      trailing: Chip(
        label: Text(
          estadoText,
          style: TextStyle(fontSize: 10, color: estadoColor),
        ),
        backgroundColor: estadoColor.withOpacity(0.1),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildPieChartCard(stats) {
    final total = (stats?['total_estudiantes'] ?? 0) + 
                  (stats?['total_matriculas'] ?? 0) + 
                  (stats?['total_usuarios'] ?? 0);
    
    if (total == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Tramites por tipo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              const Center(child: Text('No hay datos disponibles')),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    }

    final estudiantes = stats?['total_estudiantes'] ?? 0;
    final matriculas = stats?['total_matriculas'] ?? 0;
    final usuarios = stats?['total_usuarios'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Tramites por tipo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: estudiantes.toDouble(),
                      color: Colors.blue,
                      title: estudiantes > 0 ? '${(estudiantes / total * 100).toStringAsFixed(0)}%' : '',
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: matriculas.toDouble(),
                      color: Colors.green,
                      title: matriculas > 0 ? '${(matriculas / total * 100).toStringAsFixed(0)}%' : '',
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: usuarios.toDouble(),
                      color: Colors.purple,
                      title: usuarios > 0 ? '${(usuarios / total * 100).toStringAsFixed(0)}%' : '',
                      radius: 60,
                    ),
                  ],
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(Colors.blue, 'Estudiantes'),
                _buildLegendItem(Colors.green, 'Matriculas'),
                _buildLegendItem(Colors.purple, 'Usuarios'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildConsultaDniCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consultas rapidas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('DNI'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dniController,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    decoration: const InputDecoration(
                      hintText: 'Ingrese numero de DNI',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    onSubmitted: (_) => _consultarDni(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _loadingDni ? null : _consultarDni,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE31C2B),
                    foregroundColor: Colors.white,
                  ),
                  child: _loadingDni
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Buscar'),
                ),
              ],
            ),
            if (_dniError != null) ...[
              const SizedBox(height: 8),
              Text(_dniError!, style: const TextStyle(color: Colors.red)),
            ],
            if (_dniResult != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DNI: ${_dniResult!['dni'] ?? ''}'),
                    Text('Nombres: ${_dniResult!['nombres'] ?? ''}'),
                    Text('Apellidos: ${_dniResult!['apellidoPaterno'] ?? ''} ${_dniResult!['apellidoMaterno'] ?? ''}'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccionesRapidasCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acciones rapidas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ActionButton('Admision', Icons.assignment, Colors.red.shade100, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdmisionScreen()));
                }),
                ActionButton('Matricula', Icons.school, Colors.blue.shade100, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MatriculaScreen()));
                }),
                ActionButton('Convalidacion', Icons.swap_horiz, Colors.orange.shade100, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ConvalidacionScreen()));
                }),
                ActionButton('Titulacion', Icons.military_tech, Colors.purple.shade100, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TitulacionScreen()));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}