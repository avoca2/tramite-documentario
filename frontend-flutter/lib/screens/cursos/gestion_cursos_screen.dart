import "package:flutter/material.dart";
import "../services/curso_service.dart";
import "../services/nota_service.dart";
import "../models/curso.dart";
import "../models/nota.dart";
import "../utils/constants.dart";

class GestionCursosScreen extends StatefulWidget {
  final int? carreraId;

  const GestionCursosScreen({Key? key, this.carreraId}) : super(key: key);

  @override
  State<GestionCursosScreen> createState() => _GestionCursosScreenState();
}

class _GestionCursosScreenState extends State<GestionCursosScreen> {
  final CursoService _cursoService = CursoService();
  final NotaService _notaService = NotaService();
  List<Curso> _cursos = [];
  bool _isLoading = true;
  int _selectedCiclo = 0;

  @override
  void initState() {
    super.initState();
    _cargarCursos();
  }

  Future<void> _cargarCursos() async {
    setState(() => _isLoading = true);
    try {
      List<Curso> cursos;
      if (widget.carreraId != null) {
        cursos = await _cursoService.getCursosByCarrera(widget.carreraId!);
      } else {
        cursos = await _cursoService.getCursos();
      }
      setState(() {
        _cursos = cursos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar cursos: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cursosFiltrados = _selectedCiclo > 0
        ? _cursos.where((c) => c.ciclo == _selectedCiclo).toList()
        : _cursos;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Cursos"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _cargarCursos,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text("Filtrar por ciclo:"),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _selectedCiclo,
                  items: [
                    const DropdownMenuItem(value: 0, child: Text("Todos")),
                    ...List.generate(10, (i) {
                      final ciclo = i + 1;
                      return DropdownMenuItem(
                        value: ciclo,
                        child: Text("Ciclo $ciclo"),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCiclo = value ?? 0;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : cursosFiltrados.isEmpty
                    ? const Center(
                        child: Text("No hay cursos disponibles"),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cursosFiltrados.length,
                        itemBuilder: (context, index) {
                          final curso = cursosFiltrados[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ExpansionTile(
                              title: Text(curso.nombre),
                              subtitle: Text("Código: ${curso.codigo} - Ciclo ${curso.ciclo}"),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryLight,
                                child: Text(
                                  curso.ciclo.toString(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Créditos: ${curso.creditos}"),
                                      Text("Horas teoría: ${curso.horasTeoria}"),
                                      Text("Horas práctica: ${curso.horasPractica}"),
                                      if (curso.descripcion != null)
                                        Text("Descripción: ${curso.descripcion}"),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                            },
                                            child: const Text("Ver Notas"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                            ),
                                            child: const Text("Editar"),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoCrearCurso,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarDialogoCrearCurso() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Crear Curso"),
        content: const Text("Formulario para crear curso..."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}
