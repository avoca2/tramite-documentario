import "package:flutter/material.dart";
import "package:file_picker/file_picker.dart";
import "../services/documento_service.dart";
import "../services/estudiante_service.dart";
import "../models/documento.dart";
import "../models/estudiante.dart";
import "../utils/constants.dart";

class GestionDocumentosScreen extends StatefulWidget {
  final int estudianteId;

  const GestionDocumentosScreen({
    Key? key,
    required this.estudianteId,
  }) : super(key: key);

  @override
  State<GestionDocumentosScreen> createState() => _GestionDocumentosScreenState();
}

class _GestionDocumentosScreenState extends State<GestionDocumentosScreen> {
  final DocumentoService _documentoService = DocumentoService();
  final EstudianteService _estudianteService = EstudianteService();

  List<Documento> _documentos = [];
  List<TipoDocumento> _tiposDocumentos = [];
  bool _isLoading = true;
  Estudiante? _estudiante;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final estudiante = await _estudianteService.getEstudiante(widget.estudianteId);
      final documentos = await _documentoService.getDocumentosByEstudiante(widget.estudianteId);
      final tipos = await _documentoService.getTiposDocumentos();

      setState(() {
        _estudiante = estudiante;
        _documentos = documentos;
        _tiposDocumentos = tipos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar datos: $e")),
      );
    }
  }

  Future<void> _subirDocumento() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      // Mostrar diálogo para seleccionar tipo de documento
      final tipoSeleccionado = await showDialog<TipoDocumento>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Seleccionar tipo de documento"),
          content: DropdownButtonFormField<TipoDocumento>(
            items: _tiposDocumentos.map((tipo) {
              return DropdownMenuItem(
                value: tipo,
                child: Text(tipo.nombre),
              );
            }).toList(),
            onChanged: (value) {},
            decoration: const InputDecoration(
              labelText: "Tipo de documento",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Subir"),
            ),
          ],
        ),
      );

      if (tipoSeleccionado != null) {
        try {
          final file = result.files.first;
          await _documentoService.subirDocumento(
            estudianteId: widget.estudianteId,
            tipoDocumentoId: tipoSeleccionado.id,
            nombreArchivo: file.name,
            ruta: file.path ?? "",
            mimeType: file.extension ?? "unknown",
            tamano: file.size ~/ 1024,
          );
          _cargarDatos();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Documento subido exitosamente")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al subir: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Documentos del Estudiante"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_estudiante != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[100],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_estudiante!.nombres} ${_estudiante!.apellidos}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text("DNI: ${_estudiante!.dni}"),
                        Text("Carrera: ${_estudiante!.carrera?.nombre ?? "No asignada"}"),
                      ],
                    ),
                  ),
                Expanded(
                  child: _documentos.isEmpty
                      ? const Center(
                          child: Text("No hay documentos registrados"),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _documentos.length,
                          itemBuilder: (context, index) {
                            final doc = _documentos[index];
                            final tipo = _tiposDocumentos.firstWhere(
                              (t) => t.id == doc.tipoDocumentoId,
                              orElse: () => TipoDocumento(
                                id: 0,
                                nombre: "Desconocido",
                                codigo: "",
                                obligatorio: false,
                                formatoPermitidos: "",
                                tamanoMaximo: 0,
                                activo: false,
                              ),
                            );
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: _getIconForDocument(doc),
                                title: Text(doc.nombreArchivo),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Tipo: ${tipo.nombre}"),
                                    Text("Estado: ${doc.estado}"),
                                    Text("Tamaño: ${doc.tamano} KB"),
                                  ],
                                ),
                                trailing: _getStatusChip(doc.estado),
                                onTap: () {
                                  _mostrarDetalleDocumento(doc);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _subirDocumento,
        child: const Icon(Icons.upload_file),
      ),
    );
  }

  Widget _getIconForDocument(Documento doc) {
    if (doc.mimeType.contains("pdf")) {
      return const Icon(Icons.picture_as_pdf, color: Colors.red);
    } else if (doc.mimeType.contains("image")) {
      return const Icon(Icons.image, color: Colors.green);
    } else {
      return const Icon(Icons.insert_drive_file);
    }
  }

  Widget _getStatusChip(String estado) {
    Color color;
    switch (estado) {
      case "verificado":
        color = Colors.green;
        break;
      case "rechazado":
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Chip(
      label: Text(estado),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
    );
  }

  void _mostrarDetalleDocumento(Documento doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc.nombreArchivo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tamaño: ${doc.tamano} KB"),
            Text("Tipo: ${doc.mimeType}"),
            Text("Estado: ${doc.estado}"),
            if (doc.observaciones != null)
              Text("Observaciones: ${doc.observaciones}"),
            Text("Subido: ${doc.createdAt}"),
          ],
        ),
        actions: [
          if (doc.estado == "pendiente")
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _verificarDocumento(doc.id, "verificado"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Verificar"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _verificarDocumento(doc.id, "rechazado"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Rechazar"),
                ),
              ],
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  Future<void> _verificarDocumento(int documentoId, String estado) async {
    try {
      await _documentoService.verificarDocumento(documentoId, estado, null);
      _cargarDatos();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Documento $estado exitosamente")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
