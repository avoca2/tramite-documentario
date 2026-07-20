import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../services/api_service.dart';
import '../../services/admision_service.dart';
import '../../models/admision.dart';
import '../../providers/auth_provider.dart';

class AdmisionScreen extends StatefulWidget {
  const AdmisionScreen({super.key});

  @override
  State<AdmisionScreen> createState() => _AdmisionScreenState();
}

class _AdmisionScreenState extends State<AdmisionScreen> {
  late AdmisionService _admisionService;
  late ApiService _apiService;

  // Controladores
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidoPaternoController = TextEditingController();
  final TextEditingController _apellidoMaternoController = TextEditingController();
  final TextEditingController _fechaNacimientoController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _colegioController = TextEditingController();
  final TextEditingController _lugarController = TextEditingController();
  final TextEditingController _notaController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Variables de estado
  String _modalidad = 'ordinaria';
  String _estadoFiltro = 'todos';
  List<Admision> _admisiones = [];
  List<Admision> _admisionesFiltradas = [];
  bool _loading = false;
  bool _mostrarFormulario = false;
  bool _mostrarLista = true;
  String? _errorMessage;
  String? _successMessage;
  Admision? _admisionSeleccionada;
  bool _isSearching = false;

  final List<String> _modalidades = ['ordinaria', 'exoneracion'];
  final List<String> _estadosFiltro = ['todos', 'inscrito', 'evaluado', 'ingresante', 'no_ingresante'];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _apiService = ApiService();
    if (authProvider.token != null) {
      _apiService.setToken(authProvider.token!);
    }
    _admisionService = AdmisionService(_apiService.dio);
    if (authProvider.token != null) {
      _admisionService.setToken(authProvider.token!);
    }
    _cargarAdmisiones();
  }

  Future<void> _cargarAdmisiones() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        _admisionService.setToken(authProvider.token!);
      }

      final admisiones = await _admisionService.getAdmisiones();
      setState(() {
        _admisiones = admisiones;
        _admisionesFiltradas = admisiones;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar admisiones: $e';
        _loading = false;
      });
    }
  }

  void _filtrarAdmisiones() {
    setState(() {
      if (_estadoFiltro == 'todos') {
        _admisionesFiltradas = _admisiones;
      } else {
        _admisionesFiltradas = _admisiones.where((a) => a.estado == _estadoFiltro).toList();
      }
    });
  }

  void _buscarAdmisiones(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _admisionesFiltradas = _admisiones;
        return;
      }

      final lowerQuery = query.toLowerCase();
      _admisionesFiltradas = _admisiones.where((admision) {
        return admision.estudianteNombre.toLowerCase().contains(lowerQuery) ||
            admision.dni.contains(query) ||
            admision.estadoDisplay.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  Future<void> _buscarDni() async {
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
    });

    try {
      final data = await _apiService.consultarDni(dni);
      setState(() {
        _nombresController.text = data['nombres'] ?? '';
        _apellidoPaternoController.text = data['apellidoPaterno'] ?? '';
        _apellidoMaternoController.text = data['apellidoMaterno'] ?? '';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al consultar DNI: $e';
        _loading = false;
      });
    }
  }

  Future<void> _guardarInscripcion() async {
    if (_dniController.text.isEmpty || _nombresController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Complete los campos obligatorios (DNI, Nombres)';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final data = {
        'dni': _dniController.text.trim(),
        'nombres': _nombresController.text.trim(),
        'apellido_paterno': _apellidoPaternoController.text.trim(),
        'apellido_materno': _apellidoMaternoController.text.trim(),
        'fecha_nacimiento': _fechaNacimientoController.text.trim(),
        'celular': _celularController.text.trim(),
        'email': _emailController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'colegio_procedencia': _colegioController.text.trim(),
        'lugar_procedencia': _lugarController.text.trim(),
        'modalidad': _modalidad,
      };

      final result = await _admisionService.inscribir(data);

      setState(() {
        _successMessage = 'Inscripcion exitosa. Codigo: ${result['id']}';
        _loading = false;
        _limpiarFormulario();
        _mostrarFormulario = false;
        _mostrarLista = true;
      });

      await _cargarAdmisiones();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inscripcion exitosa para ${_nombresController.text}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al inscribir: $e';
        _loading = false;
      });
    }
  }

  void _limpiarFormulario() {
    _dniController.clear();
    _nombresController.clear();
    _apellidoPaternoController.clear();
    _apellidoMaternoController.clear();
    _fechaNacimientoController.clear();
    _celularController.clear();
    _emailController.clear();
    _direccionController.clear();
    _colegioController.clear();
    _lugarController.clear();
    _notaController.clear();
    _modalidad = 'ordinaria';
    _admisionSeleccionada = null;
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'inscrito':
        return Colors.orange;
      case 'evaluado':
        return Colors.blue;
      case 'ingresante':
        return Colors.green;
      case 'no_ingresante':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Proceso de Admision',
          style: TextStyle(color: Colors.white),
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
              tooltip: 'Nueva inscripcion',
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
            onPressed: _cargarAdmisiones,
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
        // Filtros y búsqueda
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            children: [
              // Buscador
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, DNI o estado...',
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
                            _buscarAdmisiones('');
                          },
                        )
                      : null,
                ),
                onChanged: _buscarAdmisiones,
              ),
              const SizedBox(height: 12),
              // Filtro por estado
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
                          _filtrarAdmisiones();
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
                      'Total: ${_admisionesFiltradas.length}',
                      style: const TextStyle(
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
        // Lista
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _admisionesFiltradas.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _admisionesFiltradas.length,
                      itemBuilder: (context, index) {
                        final admision = _admisionesFiltradas[index];
                        return _buildAdmisionCard(admision);
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
          Icon(Icons.assignment, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No hay inscripciones registradas',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Presione el boton + para iniciar una nueva inscripcion',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAdmisionCard(Admision admision) {
    final color = _getEstadoColor(admision.estado);

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
          child: Text(
            admision.dni.substring(0, 2),
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          admision.estudianteNombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('DNI: ${admision.dni}'),
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
                admision.estadoDisplay,
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
                _mostrarOpciones(admision);
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
                _buildInfoRow('Modalidad', admision.modalidadDisplay),
                _buildInfoRow('Estado', admision.estadoDisplay),
                if (admision.notaFinal != null)
                  _buildInfoRow('Nota Final', admision.notaFinal!.toStringAsFixed(1)),
                if (admision.colegioProcedencia != null && admision.colegioProcedencia!.isNotEmpty)
                  _buildInfoRow('Colegio', admision.colegioProcedencia!),
                if (admision.lugarProcedencia != null && admision.lugarProcedencia!.isNotEmpty)
                  _buildInfoRow('Lugar', admision.lugarProcedencia!),
                if (admision.fechaInscripcion != null)
                  _buildInfoRow(
                    'Fecha Inscripcion',
                    '${admision.fechaInscripcion!.day}/${admision.fechaInscripcion!.month}/${admision.fechaInscripcion!.year} ${admision.fechaInscripcion!.hour.toString().padLeft(2, '0')}:${admision.fechaInscripcion!.minute.toString().padLeft(2, '0')}',
                  ),
                if (admision.fechaEvaluacion != null)
                  _buildInfoRow(
                    'Fecha Evaluacion',
                    '${admision.fechaEvaluacion!.day}/${admision.fechaEvaluacion!.month}/${admision.fechaEvaluacion!.year} ${admision.fechaEvaluacion!.hour.toString().padLeft(2, '0')}:${admision.fechaEvaluacion!.minute.toString().padLeft(2, '0')}',
                  ),
                if (admision.observaciones != null && admision.observaciones!.isNotEmpty)
                  _buildInfoRow('Observaciones', admision.observaciones!),
                const SizedBox(height: 12),
                if (admision.estado == 'inscrito' || admision.estado == 'evaluado')
                  _buildAccionesEvaluacion(admision),
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
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccionesEvaluacion(Admision admision) {
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
            'Evaluar Postulante',
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
                onPressed: () => _evaluarPostulante(admision),
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
                  onPressed: () => _actualizarEstado(admision, 'ingresante'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green.shade700),
                    foregroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Aprobar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _actualizarEstado(admision, 'no_ingresante'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade700),
                    foregroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Rechazar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _evaluarPostulante(Admision admision) async {
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
        _admisionService.setToken(authProvider.token!);
      }

      await _admisionService.evaluar(admision.id!, nota);

      setState(() {
        _loading = false;
        _notaController.clear();
        _successMessage = 'Evaluacion registrada correctamente';
      });

      await _cargarAdmisiones();

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

  Future<void> _actualizarEstado(Admision admision, String nuevoEstado) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        _admisionService.setToken(authProvider.token!);
      }

      await _admisionService.actualizarEstado(admision.id!, nuevoEstado);

      setState(() {
        _loading = false;
        _successMessage = 'Estado actualizado a ${nuevoEstado.toUpperCase()}';
      });

      await _cargarAdmisiones();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado actualizado a ${nuevoEstado.toUpperCase()}'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al actualizar estado: $e';
        _loading = false;
      });
    }
  }

  void _mostrarOpciones(Admision admision) {
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
                leading: Icon(Icons.delete_outline, color: Colors.red.shade700),
                title: const Text('Eliminar inscripcion'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmarEliminar(admision);
                },
              ),
              ListTile(
                leading: Icon(Icons.visibility, color: AppColors.primary),
                title: const Text('Ver detalles'),
                onTap: () {
                  Navigator.pop(context);
                  _verDetalles(admision);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _confirmarEliminar(Admision admision) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminacion'),
        content: Text('Esta seguro de eliminar la inscripcion de ${admision.estudianteNombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarAdmision(admision);
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

  Future<void> _eliminarAdmision(Admision admision) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        _admisionService.setToken(authProvider.token!);
      }

      await _admisionService.eliminar(admision.id!);

      setState(() {
        _loading = false;
        _successMessage = 'Inscripcion eliminada correctamente';
      });

      await _cargarAdmisiones();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscripcion eliminada'),
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

  void _verDetalles(Admision admision) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de ${admision.estudianteNombre}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('DNI', admision.dni),
              _buildInfoRow('Modalidad', admision.modalidadDisplay),
              _buildInfoRow('Estado', admision.estadoDisplay),
              if (admision.notaFinal != null)
                _buildInfoRow('Nota', admision.notaFinal!.toStringAsFixed(1)),
              if (admision.colegioProcedencia != null && admision.colegioProcedencia!.isNotEmpty)
                _buildInfoRow('Colegio', admision.colegioProcedencia!),
              if (admision.lugarProcedencia != null && admision.lugarProcedencia!.isNotEmpty)
                _buildInfoRow('Lugar', admision.lugarProcedencia!),
              if (admision.fechaInscripcion != null)
                _buildInfoRow(
                  'Fecha Inscripcion',
                  '${admision.fechaInscripcion!.day}/${admision.fechaInscripcion!.month}/${admision.fechaInscripcion!.year}',
                ),
              if (admision.fechaEvaluacion != null)
                _buildInfoRow(
                  'Fecha Evaluacion',
                  '${admision.fechaEvaluacion!.day}/${admision.fechaEvaluacion!.month}/${admision.fechaEvaluacion!.year}',
                ),
              if (admision.observaciones != null && admision.observaciones!.isNotEmpty)
                _buildInfoRow('Observaciones', admision.observaciones!),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                  'Nueva Inscripcion',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete todos los campos obligatorios (*)',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Mensajes de error/success
          if (_errorMessage != null) _buildErrorMessage(),
          if (_successMessage != null) _buildSuccessMessage(),

          // Formulario
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Datos Personales',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // DNI con búsqueda
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
                        onPressed: _loading ? null : _buscarDni,
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

                  // Nombres
                  TextField(
                    controller: _nombresController,
                    decoration: const InputDecoration(
                      labelText: 'Nombres *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Apellidos
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _apellidoPaternoController,
                          decoration: const InputDecoration(
                            labelText: 'Apellido Paterno *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _apellidoMaternoController,
                          decoration: const InputDecoration(
                            labelText: 'Apellido Materno',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Fecha Nacimiento
                  TextField(
                    controller: _fechaNacimientoController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha Nacimiento (AAAA-MM-DD)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 12),

                  // Celular y Email
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _celularController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Celular *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Dirección
                  TextField(
                    controller: _direccionController,
                    decoration: const InputDecoration(
                      labelText: 'Direccion',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Separador
                  const Divider(),
                  const SizedBox(height: 8),

                  const Text(
                    'Datos de Admision',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Colegio y Lugar
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _colegioController,
                          decoration: const InputDecoration(
                            labelText: 'Colegio de Procedencia',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _lugarController,
                          decoration: const InputDecoration(
                            labelText: 'Lugar de Procedencia',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Modalidad
                  DropdownButtonFormField<String>(
                    value: _modalidad,
                    decoration: const InputDecoration(
                      labelText: 'Modalidad *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.how_to_reg),
                    ),
                    items: _modalidades.map((modalidad) {
                      return DropdownMenuItem(
                        value: modalidad,
                        child: Text(modalidad == 'ordinaria' ? 'Ordinaria' : 'Exoneracion'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _modalidad = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _loading ? null : _guardarInscripcion,
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
                              : const Text(
                                  'Inscribir',
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
    _nombresController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _fechaNacimientoController.dispose();
    _celularController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    _colegioController.dispose();
    _lugarController.dispose();
    _notaController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}