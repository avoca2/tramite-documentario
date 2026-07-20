import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../services/api_service.dart';
import '../../services/matricula_service.dart';
import '../../models/matricula.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';

class MatriculaScreen extends StatefulWidget {
  const MatriculaScreen({super.key});

  @override
  State<MatriculaScreen> createState() => _MatriculaScreenState();
}

class _MatriculaScreenState extends State<MatriculaScreen> {
  late MatriculaService _matriculaService;
  late ApiService _apiService;

  // Controladores
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _estudianteController = TextEditingController();
  final TextEditingController _periodoController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _comprobanteController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Variables de estado
  String _tipoMatricula = 'regular';
  String _estadoFiltro = 'todos';
  List<Matricula> _matriculas = [];
  List<Matricula> _matriculasFiltradas = [];
  bool _loading = false;
  bool _mostrarFormulario = false;
  bool _mostrarLista = true;
  String? _errorMessage;
  String? _successMessage;
  Matricula? _matriculaSeleccionada;
  bool _isSearching = false;
  int? _estudianteIdEncontrado;

  final List<String> _tiposMatricula = ['ingresante', 'regular', 'extemporanea', 'reserva'];
  final List<String> _estadosFiltro = ['todos', 'activo', 'inactivo', 'reserva'];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _apiService = ApiService();
    if (authProvider.token != null) {
      _apiService.setToken(authProvider.token!);
    }
    _matriculaService = MatriculaService(_apiService.dio);
    if (authProvider.token != null) {
      _matriculaService.setToken(authProvider.token!);
    }
    _cargarMatriculas();
  }

  Future<void> _cargarMatriculas() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final roleProvider = Provider.of<RoleProvider>(context, listen: false);
      
      if (authProvider.token != null) {
        _matriculaService.setToken(authProvider.token!);
      }

      final matriculas = await _matriculaService.getMatriculas();
      
      setState(() {
        _matriculas = matriculas;
        _matriculasFiltradas = matriculas;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar matrículas: $e';
        _loading = false;
      });
    }
  }

  void _filtrarMatriculas() {
    setState(() {
      if (_estadoFiltro == 'todos') {
        _matriculasFiltradas = _matriculas;
      } else {
        _matriculasFiltradas = _matriculas.where((m) => m.estado == _estadoFiltro).toList();
      }
    });
  }

  void _buscarMatriculas(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _matriculasFiltradas = _matriculas;
        return;
      }

      final lowerQuery = query.toLowerCase();
      _matriculasFiltradas = _matriculas.where((matricula) {
        return matricula.estudianteNombre.toLowerCase().contains(lowerQuery) ||
            matricula.dni.contains(query) ||
            matricula.codigoMatricula.toLowerCase().contains(lowerQuery) ||
            matricula.periodoAcademico.toLowerCase().contains(lowerQuery);
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estudiante encontrado. Complete los datos para la matrícula.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al consultar DNI: $e';
        _loading = false;
      });
    }
  }

  Future<void> _guardarMatricula() async {
    final dni = _dniController.text.trim();
    if (dni.isEmpty) {
      setState(() {
        _errorMessage = 'Ingrese el DNI del estudiante';
      });
      return;
    }

    if (_periodoController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Ingrese el periodo academico';
      });
      return;
    }

    if (_montoController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Ingrese el monto pagado';
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
        _matriculaService.setToken(authProvider.token!);
      }

      final data = {
        'dni': dni,
        'periodo_academico': _periodoController.text.trim(),
        'tipo': _tipoMatricula,
        'monto_pagado': double.tryParse(_montoController.text.trim()) ?? 0,
        'comprobante_pago': _comprobanteController.text.trim(),
        'observaciones': _observacionesController.text.trim(),
      };

      final result = await _matriculaService.registrarMatricula(data);

      setState(() {
        _successMessage = 'Matricula registrada exitosamente. Codigo: ${result['codigo_matricula']}';
        _loading = false;
        _limpiarFormulario();
        _mostrarFormulario = false;
        _mostrarLista = true;
      });

      await _cargarMatriculas();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Matricula registrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al registrar matrícula: $e';
        _loading = false;
      });
    }
  }

  void _limpiarFormulario() {
    _dniController.clear();
    _estudianteController.clear();
    _periodoController.clear();
    _montoController.clear();
    _comprobanteController.clear();
    _observacionesController.clear();
    _tipoMatricula = 'regular';
    _matriculaSeleccionada = null;
    _estudianteIdEncontrado = null;
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'activo':
        return Colors.green;
      case 'inactivo':
        return Colors.red;
      case 'reserva':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'ingresante':
        return Colors.blue;
      case 'regular':
        return Colors.green;
      case 'extemporanea':
        return Colors.orange;
      case 'reserva':
        return Colors.purple;
      default:
        return Colors.grey;
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
              isEstudiante ? 'Mi Matrícula' : 'Gestión de Matrículas',
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
              tooltip: 'Nueva matricula',
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
            onPressed: _cargarMatriculas,
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
                  hintText: 'Buscar por nombre, DNI, codigo o periodo...',
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
                            _buscarMatriculas('');
                          },
                        )
                      : null,
                ),
                onChanged: _buscarMatriculas,
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
                          _filtrarMatriculas();
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
                      'Total: ${_matriculasFiltradas.length}',
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
              : _matriculasFiltradas.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _matriculasFiltradas.length,
                      itemBuilder: (context, index) {
                        final matricula = _matriculasFiltradas[index];
                        return _buildMatriculaCard(matricula);
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
          Icon(Icons.school, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No hay matriculas registradas',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Presione el boton + para registrar una nueva matricula',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMatriculaCard(Matricula matricula) {
    final estadoColor = _getEstadoColor(matricula.estado);
    final tipoColor = _getTipoColor(matricula.tipo);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: estadoColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: estadoColor,
          child: Text(
            matricula.codigoMatricula.substring(0, 2),
            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          matricula.estudianteNombre,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${matricula.dni} - ${matricula.periodoAcademico}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tipoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tipoColor.withOpacity(0.3)),
              ),
              child: Text(
                matricula.tipoDisplay,
                style: TextStyle(
                  color: tipoColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: estadoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: estadoColor.withOpacity(0.3)),
              ),
              child: Text(
                matricula.estadoDisplay,
                style: TextStyle(
                  color: estadoColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.more_vert, size: 20),
              onPressed: () {
                _mostrarOpciones(matricula);
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
                _buildInfoRow('Codigo', matricula.codigoMatricula),
                _buildInfoRow('Estudiante', matricula.estudianteNombre),
                _buildInfoRow('DNI', matricula.dni),
                _buildInfoRow('Carrera', matricula.carrera),
                _buildInfoRow('Periodo', matricula.periodoAcademico),
                _buildInfoRow('Tipo', matricula.tipoDisplay),
                _buildInfoRow('Estado', matricula.estadoDisplay),
                if (matricula.montoPagado != null)
                  _buildInfoRow('Monto Pagado', 'S/. ${matricula.montoPagado!.toStringAsFixed(2)}'),
                if (matricula.fechaMatricula != null)
                  _buildInfoRow(
                    'Fecha Matricula',
                    '${matricula.fechaMatricula!.day}/${matricula.fechaMatricula!.month}/${matricula.fechaMatricula!.year}',
                  ),
                if (matricula.comprobantePago != null && matricula.comprobantePago!.isNotEmpty)
                  _buildInfoRow('Comprobante', matricula.comprobantePago!),
                if (matricula.observaciones != null && matricula.observaciones!.isNotEmpty)
                  _buildInfoRow('Observaciones', matricula.observaciones!),
                const SizedBox(height: 12),
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

  void _mostrarOpciones(Matricula matricula) {
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
                title: const Text('Eliminar matricula'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmarEliminar(matricula);
                },
              ),
              ListTile(
                leading: Icon(Icons.visibility, color: AppColors.primary),
                title: const Text('Ver detalles'),
                onTap: () {
                  Navigator.pop(context);
                  _verDetalles(matricula);
                },
              ),
              if (matricula.estado == 'activo')
                ListTile(
                  leading: Icon(Icons.pause, color: Colors.orange.shade700),
                  title: const Text('Poner en reserva'),
                  onTap: () {
                    Navigator.pop(context);
                    _actualizarEstado(matricula, 'reserva');
                  },
                ),
              if (matricula.estado == 'reserva')
                ListTile(
                  leading: Icon(Icons.play_arrow, color: Colors.green.shade700),
                  title: const Text('Activar matricula'),
                  onTap: () {
                    Navigator.pop(context);
                    _actualizarEstado(matricula, 'activo');
                  },
                ),
              ListTile(
                leading: Icon(Icons.cancel, color: Colors.red.shade700),
                title: const Text('Inactivar matricula'),
                onTap: () {
                  Navigator.pop(context);
                  _actualizarEstado(matricula, 'inactivo');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _actualizarEstado(Matricula matricula, String nuevoEstado) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        _matriculaService.setToken(authProvider.token!);
      }

      await _matriculaService.actualizarMatricula(matricula.id!, {
        'estado': nuevoEstado,
      });

      setState(() {
        _loading = false;
        _successMessage = 'Estado actualizado a ${nuevoEstado.toUpperCase()}';
      });

      await _cargarMatriculas();

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

  void _confirmarEliminar(Matricula matricula) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminacion'),
        content: Text('Esta seguro de eliminar la matricula de ${matricula.estudianteNombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarMatricula(matricula);
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

  Future<void> _eliminarMatricula(Matricula matricula) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        _matriculaService.setToken(authProvider.token!);
      }

      await _matriculaService.eliminarMatricula(matricula.id!);

      setState(() {
        _loading = false;
        _successMessage = 'Matricula eliminada correctamente';
      });

      await _cargarMatriculas();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Matricula eliminada'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al eliminar matricula: $e';
        _loading = false;
      });
    }
  }

  void _verDetalles(Matricula matricula) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Matricula'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Codigo', matricula.codigoMatricula),
              _buildInfoRow('Estudiante', matricula.estudianteNombre),
              _buildInfoRow('DNI', matricula.dni),
              _buildInfoRow('Carrera', matricula.carrera),
              _buildInfoRow('Periodo', matricula.periodoAcademico),
              _buildInfoRow('Tipo', matricula.tipoDisplay),
              _buildInfoRow('Estado', matricula.estadoDisplay),
              if (matricula.montoPagado != null)
                _buildInfoRow('Monto', 'S/. ${matricula.montoPagado!.toStringAsFixed(2)}'),
              if (matricula.fechaMatricula != null)
                _buildInfoRow('Fecha', 
                  '${matricula.fechaMatricula!.day}/${matricula.fechaMatricula!.month}/${matricula.fechaMatricula!.year}'),
              if (matricula.comprobantePago != null && matricula.comprobantePago!.isNotEmpty)
                _buildInfoRow('Comprobante', matricula.comprobantePago!),
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
                  isSecretaria ? 'Nueva Matricula' : 'Solicitar Matricula',
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
                    : 'Solicite su matricula completando los campos obligatorios (*)',
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
                    'Datos de Matricula',
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
                        child: TextField(
                          controller: _periodoController,
                          decoration: const InputDecoration(
                            labelText: 'Periodo Academico *',
                            hintText: '2025-1',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _montoController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Monto Pagado (S/.) *',
                            hintText: '1500.00',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.money),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _tipoMatricula,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Matricula *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    items: _tiposMatricula.map((tipo) {
                      return DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo.substring(0, 1).toUpperCase() + tipo.substring(1)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _tipoMatricula = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _comprobanteController,
                    decoration: const InputDecoration(
                      labelText: 'Numero de Comprobante',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.receipt),
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
                          onPressed: _loading ? null : _guardarMatricula,
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
                                  isSecretaria ? 'Registrar Matricula' : 'Solicitar Matricula',
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
    _periodoController.dispose();
    _montoController.dispose();
    _comprobanteController.dispose();
    _observacionesController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}