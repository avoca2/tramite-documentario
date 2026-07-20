import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../services/api_service.dart';
import '../../services/titulacion_service.dart';
import '../../models/titulacion.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';

class TitulacionScreen extends StatefulWidget {
  const TitulacionScreen({super.key});

  @override
  State<TitulacionScreen> createState() => _TitulacionScreenState();
}

class _TitulacionScreenState extends State<TitulacionScreen> {
  late TitulacionService _titulacionService;
  late ApiService _apiService;

  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _estudianteController = TextEditingController();
  final TextEditingController _proyectoController = TextEditingController();
  final TextEditingController _fechaExamenController = TextEditingController();
  final TextEditingController _notaController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _modalidad = 'innovacion_tecnologica';
  String _estadoFiltro = 'todos';
  List<Titulacion> _titulaciones = [];
  List<Titulacion> _titulacionesFiltradas = [];
  bool _loading = false;
  bool _mostrarFormulario = false;
  bool _mostrarLista = true;
  String? _errorMessage;
  String? _successMessage;
  Titulacion? _titulacionSeleccionada;
  int? _estudianteIdEncontrado;

  final List<String> _modalidades = ['innovacion_tecnologica', 'suficiencia_profesional'];
  final List<String> _estadosFiltro = ['todos', 'en_proceso', 'aprobado', 'desaprobado', 'titulado', 'reprogramado'];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _apiService = ApiService();
    if (authProvider.token != null) {
      _apiService.setToken(authProvider.token!);
    }
    _titulacionService = TitulacionService(_apiService.dio);
    if (authProvider.token != null) {
      _titulacionService.setToken(authProvider.token!);
    }
    _cargarTitulaciones();
  }

  Future<void> _cargarTitulaciones() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        _titulacionService.setToken(authProvider.token!);
      }

      final titulaciones = await _titulacionService.getTitulaciones();
      setState(() {
        _titulaciones = titulaciones;
        _titulacionesFiltradas = titulaciones;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar titulaciones: $e';
        _loading = false;
      });
    }
  }

  void _filtrarTitulaciones() {
    setState(() {
      if (_estadoFiltro == 'todos') {
        _titulacionesFiltradas = _titulaciones;
      } else {
        _titulacionesFiltradas = _titulaciones.where((t) => t.estado == _estadoFiltro).toList();
      }
    });
  }

  void _buscarTitulaciones(String query) {
    setState(() {
      if (query.isEmpty) {
        _titulacionesFiltradas = _titulaciones;
        return;
      }

      final lowerQuery = query.toLowerCase();
      _titulacionesFiltradas = _titulaciones.where((t) {
        return t.estudianteNombre.toLowerCase().contains(lowerQuery) ||
            t.dni.contains(query) ||
            t.modalidadDisplay.toLowerCase().contains(lowerQuery) ||
            t.numeroResolucion?.toLowerCase().contains(lowerQuery) == true;
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

  Future<void> _guardarTitulacion() async {
    final dni = _dniController.text.trim();
    if (dni.isEmpty) {
      setState(() {
        _errorMessage = 'Ingrese el DNI del estudiante';
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
        _titulacionService.setToken(authProvider.token!);
      }

      final data = {
        'dni': dni,
        'modalidad': _modalidad,
        'proyecto_nombre': _proyectoController.text.trim(),
        'fecha_examen': _fechaExamenController.text.trim(),
        'observaciones': _observacionesController.text.trim(),
      };

      final result = await _titulacionService.solicitarTitulacion(data);

      setState(() {
        _successMessage = 'Solicitud registrada. Resolucion: ${result['numero_resolucion']}';
        _loading = false;
        _limpiarFormulario();
        _mostrarFormulario = false;
        _mostrarLista = true;
      });

      await _cargarTitulaciones();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud de titulación registrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al registrar titulación: $e';
        _loading = false;
      });
    }
  }

  void _limpiarFormulario() {
    _dniController.clear();
    _estudianteController.clear();
    _proyectoController.clear();
    _fechaExamenController.clear();
    _notaController.clear();
    _observacionesController.clear();
    _modalidad = 'innovacion_tecnologica';
    _titulacionSeleccionada = null;
    _estudianteIdEncontrado = null;
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'en_proceso':
        return Colors.orange;
      case 'aprobado':
        return Colors.green;
      case 'desaprobado':
        return Colors.red;
      case 'titulado':
        return Colors.blue;
      case 'reprogramado':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'en_proceso':
        return Icons.pending;
      case 'aprobado':
        return Icons.check_circle;
      case 'desaprobado':
        return Icons.cancel;
      case 'titulado':
        return Icons.verified;
      case 'reprogramado':
        return Icons.update;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleProvider = Provider.of<RoleProvider>(context);
    final isEstudiante = roleProvider.rol == 'estudiante';
    final isSecretaria = roleProvider.rol == 'secretaria' || roleProvider.rol == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEstudiante ? 'Mi Titulación' : 'Gestión de Titulaciones',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!isEstudiante && !_mostrarFormulario)
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
            onPressed: _cargarTitulaciones,
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
                  hintText: 'Buscar por nombre, DNI, resolucion o modalidad...',
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
                            _buscarTitulaciones('');
                          },
                        )
                      : null,
                ),
                onChanged: _buscarTitulaciones,
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
                          _filtrarTitulaciones();
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
                      'Total: ${_titulacionesFiltradas.length}',
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
              : _titulacionesFiltradas.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _titulacionesFiltradas.length,
                      itemBuilder: (context, index) {
                        final titulacion = _titulacionesFiltradas[index];
                        return _buildTitulacionCard(titulacion);
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
          Icon(Icons.grade, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No hay solicitudes de titulación',
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

  Widget _buildTitulacionCard(Titulacion titulacion) {
    final color = _getEstadoColor(titulacion.estado);
    final icon = _getEstadoIcon(titulacion.estado);

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
          titulacion.estudianteNombre,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${titulacion.dni} - ${titulacion.modalidadDisplay}'),
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
                titulacion.estadoDisplay,
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
                _mostrarOpciones(titulacion);
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
                _buildInfoRow('Resolucion', titulacion.numeroResolucion ?? 'Pendiente'),
                _buildInfoRow('Estudiante', titulacion.estudianteNombre),
                _buildInfoRow('DNI', titulacion.dni),
                _buildInfoRow('Carrera', titulacion.carrera),
                _buildInfoRow('Modalidad', titulacion.modalidadDisplay),
                _buildInfoRow('Estado', titulacion.estadoDisplay),
                if (titulacion.numeroTitulo != null)
                  _buildInfoRow('Numero Titulo', titulacion.numeroTitulo!),
                if (titulacion.proyectoNombre != null && titulacion.proyectoNombre!.isNotEmpty)
                  _buildInfoRow('Proyecto', titulacion.proyectoNombre!),
                if (titulacion.notaExamen != null)
                  _buildInfoRow('Nota Examen', titulacion.notaExamen!.toStringAsFixed(1)),
                if (titulacion.fechaExamen != null)
                  _buildInfoRow(
                    'Fecha Examen',
                    '${titulacion.fechaExamen!.day}/${titulacion.fechaExamen!.month}/${titulacion.fechaExamen!.year}',
                  ),
                if (titulacion.fechaSolicitud != null)
                  _buildInfoRow(
                    'Fecha Solicitud',
                    '${titulacion.fechaSolicitud!.day}/${titulacion.fechaSolicitud!.month}/${titulacion.fechaSolicitud!.year}',
                  ),
                if (titulacion.fechaTitulacion != null)
                  _buildInfoRow(
                    'Fecha Titulacion',
                    '${titulacion.fechaTitulacion!.day}/${titulacion.fechaTitulacion!.month}/${titulacion.fechaTitulacion!.year}',
                  ),
                if (titulacion.observaciones != null && titulacion.observaciones!.isNotEmpty)
                  _buildInfoRow('Observaciones', titulacion.observaciones!),
                const SizedBox(height: 12),
                if (titulacion.estado == 'en_proceso')
                  _buildAccionesEvaluacion(titulacion),
                if (titulacion.estado == 'aprobado')
                  _buildAccionesOtorgar(titulacion),
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

  Widget _buildAccionesEvaluacion(Titulacion titulacion) {
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);
    final isSecretaria = roleProvider.rol == 'secretaria' || roleProvider.rol == 'admin';

    if (!isSecretaria) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evaluar Examen',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _notaController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Nota (0-20)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    prefixIcon: const Icon(Icons.grade, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _evaluarExamen(titulacion),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Evaluar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _reprogramarExamen(titulacion),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.orange.shade700),
                    foregroundColor: Colors.orange.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Reprogramar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccionesOtorgar(Titulacion titulacion) {
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);
    final isSecretaria = roleProvider.rol == 'secretaria' || roleProvider.rol == 'admin';

    if (!isSecretaria) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Otorgar Titulo',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _otorgarTitulo(titulacion),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Otorgar Titulo'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _evaluarExamen(Titulacion titulacion) async {
    final notaText = _notaController.text.trim();
    if (notaText.isEmpty) {
      setState(() {
        _errorMessage = 'Ingrese una nota';
      });
      return;
    }

    final nota = double.tryParse(notaText);
    if (nota == null || nota < 0 || nota > 20) {
      setState(() {
        _errorMessage = 'Ingrese una nota valida entre 0 y 20';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        _titulacionService.setToken(authProvider.token!);
      }

      await _titulacionService.evaluar(titulacion.id!, nota);

      setState(() {
        _loading = false;
        _notaController.clear();
        _successMessage = 'Evaluacion registrada correctamente';
      });

      await _cargarTitulaciones();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evaluacion registrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al evaluar: $e';
        _loading = false;
      });
    }
  }

  Future<void> _reprogramarExamen(Titulacion titulacion) async {
    final fechaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reprogramar Examen'),
        content: TextField(
          controller: fechaController,
          decoration: const InputDecoration(
            labelText: 'Nueva fecha (YYYY-MM-DD)',
            hintText: '2025-12-31',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _guardarReprogramacion(titulacion, fechaController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarReprogramacion(Titulacion titulacion, String fecha) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        _titulacionService.setToken(authProvider.token!);
      }

      await _titulacionService.reprogramarExamen(titulacion.id!, fecha);

      setState(() {
        _loading = false;
        _successMessage = 'Examen reprogramado exitosamente';
      });

      await _cargarTitulaciones();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Examen reprogramado exitosamente'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al reprogramar: $e';
        _loading = false;
      });
    }
  }

  Future<void> _otorgarTitulo(Titulacion titulacion) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Otorgar Titulo'),
        content: Text(
          'Esta seguro de otorgar el titulo a ${titulacion.estudianteNombre}?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmarOtorgar(titulacion);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarOtorgar(Titulacion titulacion) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        _titulacionService.setToken(authProvider.token!);
      }

      await _titulacionService.otorgarTitulo(titulacion.id!);

      setState(() {
        _loading = false;
        _successMessage = 'Titulo otorgado exitosamente';
      });

      await _cargarTitulaciones();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Titulo otorgado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al otorgar titulo: $e';
        _loading = false;
      });
    }
  }

  void _mostrarOpciones(Titulacion titulacion) {
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);
    final isSecretaria = roleProvider.rol == 'secretaria' || roleProvider.rol == 'admin';

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
                  _verDetalles(titulacion);
                },
              ),
              if (isSecretaria && titulacion.estado != 'titulado' && titulacion.estado != 'desaprobado')
                ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red.shade700),
                  title: const Text('Eliminar solicitud'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmarEliminar(titulacion);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _confirmarEliminar(Titulacion titulacion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminacion'),
        content: Text('Esta seguro de eliminar la solicitud de ${titulacion.estudianteNombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarTitulacion(titulacion);
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

  Future<void> _eliminarTitulacion(Titulacion titulacion) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        _titulacionService.setToken(authProvider.token!);
      }

      await _titulacionService.eliminarTitulacion(titulacion.id!);

      setState(() {
        _loading = false;
        _successMessage = 'Solicitud eliminada';
      });

      await _cargarTitulaciones();

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

  void _verDetalles(Titulacion titulacion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Titulación'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Resolucion', titulacion.numeroResolucion ?? 'Pendiente'),
              _buildInfoRow('Estudiante', titulacion.estudianteNombre),
              _buildInfoRow('DNI', titulacion.dni),
              _buildInfoRow('Carrera', titulacion.carrera),
              _buildInfoRow('Modalidad', titulacion.modalidadDisplay),
              _buildInfoRow('Estado', titulacion.estadoDisplay),
              if (titulacion.numeroTitulo != null)
                _buildInfoRow('Numero Titulo', titulacion.numeroTitulo!),
              if (titulacion.proyectoNombre != null && titulacion.proyectoNombre!.isNotEmpty)
                _buildInfoRow('Proyecto', titulacion.proyectoNombre!),
              if (titulacion.notaExamen != null)
                _buildInfoRow('Nota Examen', titulacion.notaExamen!.toStringAsFixed(1)),
              if (titulacion.fechaExamen != null)
                _buildInfoRow('Fecha Examen', 
                  '${titulacion.fechaExamen!.day}/${titulacion.fechaExamen!.month}/${titulacion.fechaExamen!.year}'),
              if (titulacion.fechaSolicitud != null)
                _buildInfoRow('Fecha Solicitud',
                  '${titulacion.fechaSolicitud!.day}/${titulacion.fechaSolicitud!.month}/${titulacion.fechaSolicitud!.year}'),
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
                  isSecretaria ? 'Nueva Solicitud de Titulación' : 'Solicitar Titulación',
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
                    : 'Solicite su titulación completando los campos obligatorios (*)',
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
                    'Datos de Titulación',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _modalidad,
                    decoration: const InputDecoration(
                      labelText: 'Modalidad *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    items: _modalidades.map((modalidad) {
                      return DropdownMenuItem(
                        value: modalidad,
                        child: Text(modalidad == 'innovacion_tecnologica' 
                          ? 'Innovación Tecnológica' 
                          : 'Suficiencia Profesional'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _modalidad = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _proyectoController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Proyecto',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _fechaExamenController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha Examen (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.datetime,
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
                          onPressed: _loading ? null : _guardarTitulacion,
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
    _proyectoController.dispose();
    _fechaExamenController.dispose();
    _notaController.dispose();
    _observacionesController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}