import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../tramites/matricula_screen.dart';
import '../tramites/convalidacion_screen.dart';
import '../tramites/titulacion_screen.dart';
import '../tramites/mis_tramites_screen.dart';

class SecretariaDashboardScreen extends StatefulWidget {
  const SecretariaDashboardScreen({super.key});

  @override
  State<SecretariaDashboardScreen> createState() => _SecretariaDashboardScreenState();
}

class _SecretariaDashboardScreenState extends State<SecretariaDashboardScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _searchResult;
  bool _loading = false;
  String _searchType = 'dni';
  String? _errorMessage;
  bool _hasSearched = false;
  final List<Map<String, dynamic>> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      _apiService.setToken(authProvider.token!);
    }
  }

  Future<void> _buscar() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _errorMessage = 'Ingrese un DNI o RUC para buscar';
      });
      return;
    }

    if (_searchType == 'dni' && query.length < 8) {
      setState(() {
        _errorMessage = 'Ingrese un DNI valido (8 digitos)';
      });
      return;
    }

    if (_searchType == 'ruc' && query.length < 11) {
      setState(() {
        _errorMessage = 'Ingrese un RUC valido (11 digitos)';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      Map<String, dynamic> data;
      if (_searchType == 'dni') {
        data = await _apiService.consultarDni(query);
      } else {
        data = await _apiService.consultarRuc(query);
      }

      setState(() {
        _searchResult = data;
        _loading = false;
        _searchHistory.insert(0, {
          'type': _searchType,
          'query': query,
          'result': data,
          'timestamp': DateTime.now(),
        });
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _loading = false;
        _searchResult = null;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResult = null;
      _errorMessage = null;
      _hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final roleProvider = Provider.of<RoleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panel de Secretaria',
          style: TextStyle(color: Colors.white),
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
            child: const Text(
              'SECRETARIA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final roleProvider = Provider.of<RoleProvider>(context, listen: false);
              authProvider.logout();
              roleProvider.clear();
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: 'Cerrar Sesion',
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(authProvider),
              const SizedBox(height: 20),
              _buildSearchCard(),
              const SizedBox(height: 20),
              if (_loading) _buildLoadingIndicator(),
              if (_errorMessage != null) _buildErrorMessage(),
              if (_searchResult != null && !_loading) _buildResultCard(),
              if (_hasSearched && _searchResult == null && _errorMessage == null && !_loading)
                _buildNoResultsCard(),
              if (_searchHistory.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildHistoryCard(),
              ],
              const SizedBox(height: 20),
              _buildModulesCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(AuthProvider authProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: Text(
                  authProvider.user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenida/o, ${authProvider.user?.name ?? "Usuario"}!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authProvider.user?.email ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Colors.green, size: 10),
                    SizedBox(width: 4),
                    Text(
                      'Activo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.search, color: AppColors.primary, size: 28),
                SizedBox(width: 8),
                Text(
                  'Consultas SUNAT/RENIEC',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Realice consultas de DNI o RUC de forma rapida y segura',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTypeButton('DNI', 'dni'),
                const SizedBox(width: 10),
                _buildTypeButton('RUC', 'ruc'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    keyboardType: TextInputType.number,
                    maxLength: _searchType == 'dni' ? 8 : 11,
                    decoration: InputDecoration(
                      labelText: _searchType == 'dni' ? 'Ingrese DNI' : 'Ingrese RUC',
                      hintText: _searchType == 'dni' ? 'Ej: 12345678' : 'Ej: 20131312955',
                      prefixIcon: Icon(
                        _searchType == 'dni' ? Icons.person : Icons.business,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      counterText: '',
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: _clearSearch,
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _buscar(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _loading ? null : _buscar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(100, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          children: [
                            Icon(Icons.search),
                            SizedBox(width: 4),
                            Text('Buscar'),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, String value) {
    final isSelected = _searchType == value;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _searchType = value;
            _searchResult = null;
            _errorMessage = null;
            _searchController.clear();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primary : Colors.grey.shade200,
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              value == 'dni' ? Icons.person : Icons.business,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Consultando ${_searchType == 'dni' ? 'DNI' : 'RUC'}...',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final data = _searchResult!;
    final isDni = _searchType == 'dni';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.primaryLight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isDni ? 'DNI' : 'RUC',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: _clearSearch,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildResultItem(
                icon: Icons.numbers,
                label: isDni ? 'DNI' : 'RUC',
                value: data[isDni ? 'dni' : 'ruc']?.toString() ?? 'N/A',
              ),
              if (isDni) ...[
                _buildResultItem(
                  icon: Icons.person,
                  label: 'Nombres',
                  value: data['nombres'] ?? 'N/A',
                ),
                _buildResultItem(
                  icon: Icons.person_outline,
                  label: 'Apellido Paterno',
                  value: data['apellidoPaterno'] ?? 'N/A',
                ),
                _buildResultItem(
                  icon: Icons.person_outline,
                  label: 'Apellido Materno',
                  value: data['apellidoMaterno'] ?? 'N/A',
                ),
                if (data['codVerifica'] != null)
                  _buildResultItem(
                    icon: Icons.verified,
                    label: 'Codigo Verificacion',
                    value: '${data['codVerifica']} (${data['codVerificaLetra'] ?? ''})',
                  ),
              ] else ...[
                _buildResultItem(
                  icon: Icons.business,
                  label: 'Razon Social',
                  value: data['razon_social'] ?? 'N/A',
                ),
                if (data['nombre_comercial'] != null)
                  _buildResultItem(
                    icon: Icons.store,
                    label: 'Nombre Comercial',
                    value: data['nombre_comercial'] ?? 'N/A',
                  ),
                _buildResultItem(
                  icon: Icons.check_circle,
                  label: 'Estado',
                  value: data['estado'] ?? 'N/A',
                ),
                _buildResultItem(
                  icon: Icons.info,
                  label: 'Condicion',
                  value: data['condicion'] ?? 'N/A',
                ),
                if (data['direccion'] != null)
                  _buildResultItem(
                    icon: Icons.location_on,
                    label: 'Direccion',
                    value: data['direccion'] ?? 'N/A',
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsCard() {
    return Card(
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'No se encontraron resultados',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Intente con otro ${_searchType == 'dni' ? 'DNI' : 'RUC'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Historial de Busquedas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._searchHistory.map((item) => _buildHistoryItem(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final isDni = item['type'] == 'dni';
    final result = item['result'];
    final query = item['query'];
    final timestamp = item['timestamp'] as DateTime;

    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.primaryLight,
        child: Icon(
          isDni ? Icons.person : Icons.business,
          size: 16,
          color: AppColors.primary,
        ),
      ),
      title: Text(
        isDni ? 'DNI: $query' : 'RUC: $query',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        isDni 
          ? '${result['nombres'] ?? ''} ${result['apellidoPaterno'] ?? ''}'
          : result['razon_social'] ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      onTap: () {
        setState(() {
          _searchResult = result;
          _searchController.text = query;
          _searchType = item['type'];
          _errorMessage = null;
        });
      },
    );
  }

  Widget _buildModulesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.admin_panel_settings, color: AppColors.primary, size: 28),
                SizedBox(width: 8),
                Text(
                  'Panel de Gestion',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Gestion de tramites solicitados por los estudiantes',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildModuleButton(
                  icon: Icons.school,
                  label: 'Matriculas',
                  color: Colors.blue.shade700,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MatriculaScreen()),
                    );
                  },
                ),
                _buildModuleButton(
                  icon: Icons.swap_horiz,
                  label: 'Convalidaciones',
                  color: Colors.orange.shade700,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ConvalidacionScreen()),
                    );
                  },
                ),
                _buildModuleButton(
                  icon: Icons.grade,
                  label: 'Titulaciones',
                  color: Colors.deepOrange.shade700,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TitulacionScreen()),
                    );
                  },
                ),
                _buildModuleButton(
                  icon: Icons.list_alt,
                  label: 'Todos los Tramites',
                  color: Colors.green.shade700,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MisTramitesScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: color,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 160,
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Panel Secretaria',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'IESTP Jorge Desmaison Seminario',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.school,
            title: 'Matriculas',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MatriculaScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.swap_horiz,
            title: 'Convalidaciones',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConvalidacionScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.grade,
            title: 'Titulaciones',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TitulacionScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.list_alt,
            title: 'Todos los Tramites',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MisTramitesScreen()),
              );
            },
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            iconColor: Colors.red,
            onTap: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final roleProvider = Provider.of<RoleProvider>(context, listen: false);
              authProvider.logout();
              roleProvider.clear();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary),
      title: Text(title),
      onTap: onTap,
      hoverColor: AppColors.primaryLight,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
