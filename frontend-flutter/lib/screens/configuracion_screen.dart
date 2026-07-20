import "package:flutter/material.dart";
import "../services/configuracion_service.dart";
import "../utils/constants.dart";

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({Key? key}) : super(key: key);

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final ConfiguracionService _configuracionService = ConfiguracionService();
  Map<String, Map<String, String>> _configuraciones = {};
  bool _isLoading = true;
  String _grupoSeleccionado = "general";

  final List<String> _grupos = [
    "general",
    "academico",
    "admision",
    "matricula",
    "titulacion",
    "notificaciones",
  ];

  @override
  void initState() {
    super.initState();
    _cargarConfiguraciones();
  }

  Future<void> _cargarConfiguraciones() async {
    setState(() => _isLoading = true);
    try {
      for (final grupo in _grupos) {
        final configs = await _configuracionService.getConfiguracionesByGrupo(grupo);
        _configuraciones[grupo] = {};
        configs.forEach((key, value) {
          _configuraciones[grupo]![key] = value.toString();
        });
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar configuraciones: $e")),
      );
    }
  }

  Future<void> _actualizarConfiguracion(String grupo, String clave, String valor) async {
    try {
      await _configuracionService.actualizarConfiguracion(grupo, clave, valor);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Configuración actualizada")),
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
        title: const Text("Configuración del Sistema"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _cargarConfiguraciones,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                Container(
                  width: 200,
                  color: Colors.grey[100],
                  child: ListView.builder(
                    itemCount: _grupos.length,
                    itemBuilder: (context, index) {
                      final grupo = _grupos[index];
                      return ListTile(
                        title: Text(grupo.toUpperCase()),
                        tileColor: _grupoSeleccionado == grupo
                            ? AppColors.primaryLight
                            : null,
                        onTap: () {
                          setState(() {
                            _grupoSeleccionado = grupo;
                          });
                        },
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _grupoSeleccionado.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: _configuraciones[_grupoSeleccionado]?.isNotEmpty ?? false
                              ? ListView.builder(
                                  itemCount: _configuraciones[_grupoSeleccionado]?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final key = _configuraciones[_grupoSeleccionado]?.keys.elementAt(index) ?? "";
                                    final value = _configuraciones[_grupoSeleccionado]?[key] ?? "";
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        title: Text(key),
                                        subtitle: Text(value),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            _mostrarDialogoEditar(
                                              _grupoSeleccionado,
                                              key,
                                              value,
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Text("No hay configuraciones en este grupo"),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _mostrarDialogoEditar(String grupo, String clave, String valorActual) {
    final controller = TextEditingController(text: valorActual);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Editar $clave"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Valor",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              _actualizarConfiguracion(grupo, clave, controller.text);
              Navigator.pop(context);
              _cargarConfiguraciones();
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}
