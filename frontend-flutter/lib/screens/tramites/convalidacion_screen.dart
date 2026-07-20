import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../services/api_service.dart';
import '../../services/convalidacion_service.dart';
import '../../models/convalidacion.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';

class ConvalidacionScreen extends StatefulWidget {
  const ConvalidacionScreen({super.key});

  @override
  State<ConvalidacionScreen> createState() => _ConvalidacionScreenState();
}

class _ConvalidacionScreenState extends State<ConvalidacionScreen> {
  late ConvalidacionService _convalidacionService;
  late ApiService _apiService;

  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _estudianteController = TextEditingController();
  final TextEditingController _institucionController = TextEditingController();
  final TextEditingController _unidadesController = TextEditingController();
  final TextEditingController _creditosController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _tipoConvalidacion = 'planes_estudio';
  String _estadoFiltro = 'todos';
  List<Convalidacion> _convalidaciones = [];
  List<Convalidacion> _convalidacionesFiltradas = [];
  bool _loading = false;
  bool _mostrarFormulario = false;
  bool _mostrarLista = true;
  String? _errorMessage;
  String? _successMessage;
  Convalidacion? _convalidacionSeleccionada;
  int? _estudianteIdEncontrado;
  final List<String> _tiposConvalidacion = ['planes_estudio', 'unidades_competencia', 'efsrt'];
  final List<String> _estadosFiltro = ['todos', 'pendiente', 'en_proceso', 'aprobado', 'rechazado'];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _apiService = ApiService();
    if (authProvider.token != null) {
      _apiService.setToken(authProvider.token!);
    }
    _convalidacionService = ConvalidacionService(_apiService.dio);
    if (authProvider.token != null) {
      _convalidacionService.setToken(authProvider.token!);
    }
    _cargarConvalidaciones();
  }

  Future<void> _cargarConvalidaciones() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        _convalidacionService.setToken(authProvider.token!);
      }

      final convalidaciones = await _convalidacionService.getConvalidaciones();
      setState(() {
        _convalidaciones = convalidaciones;
        _convalidacionesFiltradas = convalidaciones;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar convalidaciones: $e';
        _loading = false;
      });
    }
  }

  void _filtrarConvalidaciones() {
    setState(() {
      if (_estadoFiltro == 'todos') {
        _convalidacionesFiltradas = _convalidaciones;
      } else {
        _convalidacionesFiltradas = _convalidaciones.where((c) => c.estado == _estadoFiltro).toList();
      }
    });
  }

  void _buscarConvalidaciones(String query) {
    setState(() {
      if (query.isEmpty) {
        _convalidacionesFiltradas = _convalidaciones;
        return;
      }

      final lowerQuery = query.toLowerCase();
      _convalidacionesFiltradas = _convalidaciones.where((c) {
        return c.estudianteNombre.toLowerCase().contains(lowerQuery) ||
            c.dni.contains(query) ||
            c.institucionOrigen.toLowerCase().contains(lowerQuery) ||
            c.tipoDisplay.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  Future<void> _buscarEstudiante() async {
    final dni = _dniController.text.trim();
    if (dni.length < 8) {
      setState(() {
        _errorMessage = 'Ingrese un DNI valido de 8 digitos';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _estudianteIdEncontrado = null;
    });

    try {
      final data = await _apiService.consultarDni(dni);
      setState(() {
        _estudianteController.text = '${data['nombres']} ${data['apellidoPaterno']} ${data['apellidoMaterno']}';
        _estudianteIdEncontrado = null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al consultar DNI: $e';
        _loading = false;
      });
    }
  }

  Future<void> _guardarConvalidacion() async {
    final dni = _dniController.text.trim();
    if (dni.isEmpty) {
      setState(() {
        _errorMessage = 'Ingrese el DNI del estudiante';
      });
      return;
    }

    if (_institucionController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Ingrese la institucion de origen';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        _convalidacionService.setToken(authProvider.token!);
      }

      final data = {
        'dni': dni,
        'tipo': _tipoConvalidacion,
        'institucion_origen': _institucionController.text.trim(),
        'unidades_convalidadas': _unidadesController.text.trim().isNotEmpty
            ? _unidadesController.text.split(',').map((e) => e.trim()).toList()
            : [],
        'total_creditos': int.tryParse(_creditosController.text.trim()) ?? 0,
        'observaciones': _observacionesController.text.trim(),
      };

      final result = await _convalidacionService.solicitarConvalidacion(data);

      setState(() {
        _successMessage = 'Solicitud registrada. Resolucion: ${result['numero_resolucion']}';
        _loading = false;
        _limpiarFormulario();
        _mostrarFormulario = false;
        _mostrarLista = true;
      });

      await _cargarConvalidaciones();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud de convalidacion registrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al registrar convalidación: $e';
        _loading = false;
      });
    }
  }

  void _limpiarFormulario() {
    _dniController.clear();
    _estudianteController.clear();
    _institucionController.clear();
    _unidadesController.clear();
    _creditosController.clear();
    _observacionesController.clear();
    _tipoConvalidacion = 'planes_estudio';
    _convalidacionSeleccionada = null;
    _estudianteIdEncontrado = null;
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange;
      case 'en_proceso':
        return Colors.blue;
      case 'aprobado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'pendiente':
        return Icons.hourglass_empty;
      case 'en_proceso':
        return Icons.pending;
      case 'aprobado':
        return Icons.check_circle;
      case 'rechazado':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<RoleProvider>(
          builder: (context, roleProvider, child) {
            final isEstudiante = roleProvider.rol == 'estudiante';
            return Text(
              isEstudiante ? 'Mi Convalidación' : 'Gestión de Convalidaciones',
              style: TextStyle(color: Colors.white),
            );
          },
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_mostrarFormulario)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _mostrarFormulario = true;
                  _mostrarLista = false;
                  _limpiarFormulario();
                });
              },
              tooltip: 'Nueva solicitud',
            ),
          if (_mostrarFormulario)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _mostrarFormulario = false;
                  _mostrarLista = true;
                  _limpiarFormulario();
                });
              },
              tooltip: 'Cancelar',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarConvalidaciones,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _mostrarFormulario ? _buildFormulario() : _buildLista(),
    );
  }

  Widget _buildLista() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, DNI, institucion o tipo...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _buscarConvalidaciones('');
                          },
                        )
                      : null,
                ),
                onChanged: _buscarConvalidaciones,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Filtrar por estado:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _estadoFiltro,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _estadosFiltro.map((estado) {
                        return DropdownMenuItem(
                          value: estado,
                          child: Text(estado == 'todos'
                              ? 'Todos'
                              : estado.substring(0, 1).toUpperCase() + estado.substring(1)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _estadoFiltro = value!;
                          _filtrarConvalidaciones();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Total: ${_convalidacionesFiltradas.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _convalidacionesFiltradas.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _convalidacionesFiltradas.length,
                      itemBuilder: (context, index) {
                        final convalidacion = _convalidacionesFiltradas[index];
                        return _buildConvalidacionCard(convalidacion);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.swap_horiz, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No hay solicitudes de convalidacion',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Presione el boton + para iniciar una nueva solicitud',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildConvalidacionCard(Convalidacion convalidacion) {
    final color = _getEstadoColor(convalidacion.estado);
    final icon = _getEstadoIcon(convalidacion.estado);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          convalidacion.estudianteNombre,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${convalidacion.dni} - ${convalidacion.tipoDisplay}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                convalidacion.estadoDisplay,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.more_vert, size: 20),
              onPressed: () {
                _mostrarOpciones(convalidacion);
              },
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Resolucion', convalidacion.numeroResolucion ?? 'Pendiente'),
                _buildInfoRow('Estudiante', convalidacion.estudianteNombre),
                _buildInfoRow('DNI', convalidacion.dni),
                _buildInfoRow('Carrera', convalidacion.carrera),
                _buildInfoRow('Tipo', convalidacion.tipoDisplay),
                _buildInfoRow('Institucion', convalidacion.institucionOrigen),
                if (convalidacion.unidadesConvalidadas != null && convalidacion.unidadesConvalidadas!.isNotEmpty)
                  _buildInfoRow('Unidades', convalidacion.unidadesConvalidadas!.join(', ')),
                _buildInfoRow('Creditos', convalidacion.totalCreditos.toString()),
                _buildInfoRow('Estado', convalidacion.estadoDisplay),
                if (convalidacion.fechaSolicitud != null)
                  _buildInfoRow(
                    'Fecha Solicitud',
                    '${convalidacion.fechaSolicitud!.day}/${convalidacion.fechaSolicitud!.month}/${convalidacion.fechaSolicitud!.year}',
                  ),
                if (convalidacion.fechaResolucion != null)
                  _buildInfoRow(
                    'Fecha Resolucion',
                    '${convalidacion.fechaResolucion!.day}/${convalidacion.fechaResolucion!.month}/${convalidacion.fechaResolucion!.year}',
                  ),
                if (convalidacion.observaciones != null && convalidacion.observaciones!.isNotEmpty)
                  _buildInfoRow('Observaciones', convalidacion.observaciones!),
                const SizedBox(height: 12),
                if (convalidacion.estado == 'pendiente' || convalidacion.estado == 'en_proceso')
                  _buildAcciones(convalidacion),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcciones(Convalidacion convalidacion) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _aprobarConvalidacion(convalidacion),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Aprobar'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _rechazarConvalidacion(convalidacion),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Rechazar'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _aprobarConvalidacion(Convalidacion convalidacion) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        _convalidacionService.setToken(authProvider.token!);
      }

      await _convalidacionService.aprobar(convalidacion.id!);

      setState(() {
        _loading = false;
        _successMessage = 'Convalidacion aprobada';
      });

      await _cargarConvalidaciones();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Convalidacion aprobada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al aprobar: $e';
        _loading = false;
      });
    }
  }

  Future<void> _rechazarConvalidacion(Convalidacion convalidacion) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        _convalidacionService.setToken(authProvider.token!);
      }

      await _convalidacionService.rechazar(convalidacion.id!);

      setState(() {
        _loading = false;
        _successMessage = 'Convalidacion rechazada';
      });

      await _cargarConvalidaciones();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Convalidacion rechazada'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al rechazar: $e';
        _loading = false;
      });
    }
  }

  void _mostrarOpciones(Convalidacion convalidacion) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.visibility, color: AppColors.primary),
                title: const Text('Ver detalles'),
                onTap: () {
                  Navigator.pop(context);
                  _verDetalles(convalidacion);
                },
              ),
              if (convalidacion.estado != 'aprobado')
                ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red.shade700),
                  title: const Text('Eliminar solicitud'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmarEliminar(convalidacion);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _confirmarEliminar(Convalidacion convalidacion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminacion'),
        content: Text('Esta seguro de eliminar la solicitud de ${convalidacion.estudianteNombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarConvalidacion(convalidacion);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarConvalidacion(Convalidacion convalidacion) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        _convalidacionService.setToken(authProvider.token!);
      }

      await _convalidacionService.eliminarConvalidacion(convalidacion.id!);

      setState(() {
        _loading = false;
        _successMessage = 'Solicitud eliminada';
      });

      await _cargarConvalidaciones();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud eliminada'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al eliminar: $e';
        _loading = false;
      });
    }
  }

  void _verDetalles(Convalidacion convalidacion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Convalidacion'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Resolucion', convalidacion.numeroResolucion ?? 'Pendiente'),
              _buildInfoRow('Estudiante', convalidacion.estudianteNombre),
              _buildInfoRow('DNI', convalidacion.dni),
              _buildInfoRow('Carrera', convalidacion.carrera),
              _buildInfoRow('Tipo', convalidacion.tipoDisplay),
              _buildInfoRow('Institucion', convalidacion.institucionOrigen),
              if (convalidacion.unidadesConvalidadas != null && convalidacion.unidadesConvalidadas!.isNotEmpty)
                _buildInfoRow('Unidades', convalidacion.unidadesConvalidadas!.join(', ')),
              _buildInfoRow('Creditos', convalidacion.totalCreditos.toString()),
              _buildInfoRow('Estado', convalidacion.estadoDisplay),
              if (convalidacion.fechaSolicitud != null)
                _buildInfoRow('Fecha Solicitud', 
                  '${convalidacion.fechaSolicitud!.day}/${convalidacion.fechaSolicitud!.month}/${convalidacion.fechaSolicitud!.year}'),
              if (convalidacion.fechaResolucion != null)
                _buildInfoRow('Fecha Resolucion',
                  '${convalidacion.fechaResolucion!.day}/${convalidacion.fechaResolucion!.month}/${convalidacion.fechaResolucion!.year}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    final roleProvider = Provider.of<RoleProvider>(context);
    final isSecretaria = roleProvider.rol == 'secretaria' || roleProvider.rol == 'admin';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSecretaria ? 'Nueva Solicitud de Convalidacion' : 'Solicitar Convalidacion',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isSecretaria 
                    ? 'Complete todos los campos obligatorios (*)'
                    : 'Solicite su convalidacion completando los campos obligatorios (*)',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_errorMessage != null) _buildErrorMessage(),
          if (_successMessage != null) _buildSuccessMessage(),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Datos del Estudiante',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _dniController,
                          keyboardType: TextInputType.number,
                          maxLength: 8,
                          decoration: const InputDecoration(
                            labelText: 'DNI *',
                            border: OutlineInputBorder(),
                            counterText: '',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _loading ? null : _buscarEstudiante,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _loading
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
                  const SizedBox(height: 12),

                  TextField(
                    controller: _estudianteController,
                    decoration: const InputDecoration(
                      labelText: 'Nombres y Apellidos *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),

                  const Divider(),
                  const SizedBox(height: 8),

                  const Text(
                    'Datos de Convalidacion',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _institucionController,
                    decoration: const InputDecoration(
                      labelText: 'Institucion de Origen *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _tipoConvalidacion,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Convalidacion *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.swap_horiz),
                    ),
                    items: _tiposConvalidacion.map((tipo) {
                      String display;
                      switch (tipo) {
                        case 'planes_estudio':
                          display = 'Planes de Estudio';
                          break;
                        case 'unidades_competencia':
                          display = 'Unidades de Competencia';
                          break;
                        case 'efsrt':
                          display = 'EFSRT';
                          break;
                        default:
                          display = tipo;
                      }
                      return DropdownMenuItem(
                        value: tipo,
                        child: Text(display),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _tipoConvalidacion = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _unidadesController,
                    decoration: const InputDecoration(
                      labelText: 'Unidades (separadas por coma)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.list),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _creditosController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total Creditos',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _observacionesController,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.comment),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _loading ? null : _guardarConvalidacion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  isSecretaria ? 'Registrar Solicitud' : 'Solicitar',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _mostrarFormulario = false;
                              _mostrarLista = true;
                              _limpiarFormulario();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
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

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: Colors.red.shade700),
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _successMessage!,
              style: TextStyle(color: Colors.green.shade700),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: Colors.green.shade700),
            onPressed: () {
              setState(() {
                _successMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dniController.dispose();
    _estudianteController.dispose();
    _institucionController.dispose();
    _unidadesController.dispose();
    _creditosController.dispose();
    _observacionesController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}