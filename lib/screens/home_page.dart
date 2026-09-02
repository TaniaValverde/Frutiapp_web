import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

import '../models/access_record.dart';
import '../services/access_log_service.dart';
import 'login_page.dart';

enum FiltroBitacora { todos, exitosos, fallidos }

class HomePage extends StatefulWidget {
  final AccessLogService logService;
  const HomePage({super.key, required this.logService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FiltroBitacora _filtro = FiltroBitacora.todos;

  List<AccessRecord> get _registrosFiltrados {
    final records = widget.logService.records;
    return switch (_filtro) {
      FiltroBitacora.exitosos => records.where((r) => r.exitoso).toList(),
      FiltroBitacora.fallidos => records.where((r) => !r.exitoso).toList(),
      FiltroBitacora.todos => records,
    };
  }

  Future<List<dynamic>> cargarProductos() async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('No se pudieron cargar los productos');
  }

  Future<void> importarBitacora() async {
    const typeGroup = XTypeGroup(
      label: 'JSON',
      extensions: ['json'],
      mimeTypes: ['application/json'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;
    try {
      widget.logService.importJson(await file.readAsString());
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitácora importada correctamente.')),
      );
    } on FormatException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('JSON inválido: ${e.message}')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo leer el archivo')),
      );
    }
  }

  void exportarBitacora() {
    final contenido = widget.logService.exportJson(_registrosFiltrados);
    final base64 = base64Encode(utf8.encode(contenido));
    web.HTMLAnchorElement()
      ..href = 'data:application/json;charset=utf-8;base64,$base64'
      ..setAttribute('download', 'bitacora_accesos.json')
      ..click();
  }

  Future<void> limpiarBitacora() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar historial'),
        content: const Text(
          'Se eliminarán todos los registros de la bitácora. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;
    widget.logService.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Historial de bitácora eliminado.')),
    );
  }

  Widget _navItem(
    IconData icon,
    String label, {
    bool selected = false,
    VoidCallback? onTap,
  }) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
    decoration: BoxDecoration(
      color: selected ? const Color(0xFF16BA80) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
    ),
    child: ListTile(
      dense: true,
      onTap: onTap,
      minLeadingWidth: 24,
      leading: Icon(icon, size: 18, color: const Color(0xFF003A52)),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF003A52)),
      ),
    ),
  );

  Widget _sidebar() => Container(
    width: 180,
    color: const Color(0xFFE5EEFF),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 28, 20, 20),
          child: Row(
            children: [
              Icon(Icons.eco, size: 18, color: Color(0xFF007B57)),
              SizedBox(width: 7),
              Text(
                'FrutiApp',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007B57),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 20, bottom: 20),
          child: Text(
            'Logistics Coordinator',
            style: TextStyle(fontSize: 9, color: Color(0xFF003A52)),
          ),
        ),
        _navItem(Icons.local_florist_outlined, 'Products', selected: true),
        const Spacer(),
        _navItem(
          Icons.logout,
          'Salir',
          onTap: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => LoginPage(logService: widget.logService),
            ),
            (_) => false,
          ),
        ),
        const SizedBox(height: 18),
      ],
    ),
  );

  Widget _buildProductos() {
    const nombres = [
      'Manzanas Rojas',
      'Bananas',
      'Naranjas',
      'Kiwis',
      'Mangos',
      'Fresas',
      'Papayas',
      'Uvas',
      'Melones',
      'Piñas',
    ];
    const iconos = [
      Icons.apple_outlined,
      Icons.eco_outlined,
      Icons.water_drop_outlined,
      Icons.spa_outlined,
    ];
    const colores = [
      Color(0xFFFFD8D8),
      Color(0xFFFFE0A1),
      Color(0xFFD7E7FF),
      Color(0xFFBEF0F4),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventario de Frutas',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<dynamic>>(
          future: cargarProductos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            final productos = snapshot.data ?? [];
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 170,
                mainAxisExtent: 150,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final producto = productos[index];
                final colorIndex = index % colores.length;
                return Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: colores[colorIndex],
                          radius: 23,
                          child: Icon(
                            iconos[colorIndex],
                            color: const Color(0xFF005D4D),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          nombres[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '₡${producto['id'] * 100}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF007B57),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _filter(String label, FiltroBitacora filtro) => ChoiceChip(
    label: Text(label, style: const TextStyle(fontSize: 11)),
    selected: _filtro == filtro,
    selectedColor: const Color(0xFF007B57),
    labelStyle: TextStyle(
      color: _filtro == filtro ? Colors.white : const Color(0xFF007B57),
    ),
    visualDensity: VisualDensity.compact,
    onSelected: (_) => setState(() => _filtro = filtro),
  );

  Widget _buildBitacora() {
    final registros = _registrosFiltrados;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bitácora de Accesos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            _filter('Todos', FiltroBitacora.todos),
            _filter('Exitosos', FiltroBitacora.exitosos),
            _filter('Fallidos', FiltroBitacora.fallidos),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: registros.isEmpty
              ? const Center(
                  child: Text(
                    'No hay registros para este filtro.',
                    style: TextStyle(fontSize: 13),
                  ),
                )
              : Column(
                  children: [
                    const _LogHeader(),
                    Expanded(
                      child: ListView.separated(
                        itemCount: registros.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: Color(0xFFEDF0F5)),
                        itemBuilder: (context, index) =>
                            _LogRow(record: registros[index]),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F8FD),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 900;
          final main = Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F8F6),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: Color(0xFF16BA80),
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestión de productos',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Control de accesos y bitácora',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF274055),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!compact) ...[
                      OutlinedButton.icon(
                        onPressed: limpiarBitacora,
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Limpiar historial'),
                        style: OutlinedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 11),
                          foregroundColor: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: importarBitacora,
                        icon: const Icon(Icons.upload_file, size: 16),
                        label: const Text('Importar JSON'),
                        style: OutlinedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 11),
                          foregroundColor: const Color(0xFF007B57),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: exportarBitacora,
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Exportar JSON'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007B57),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ],
                ),
                if (compact) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: limpiarBitacora,
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Limpiar historial'),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      ),
                      OutlinedButton.icon(
                        onPressed: importarBitacora,
                        icon: const Icon(Icons.upload_file, size: 16),
                        label: const Text('Importar JSON'),
                      ),
                      ElevatedButton.icon(
                        onPressed: exportarBitacora,
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Exportar JSON'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 28),
                if (compact)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildProductos(),
                          const SizedBox(height: 30),
                          _buildBitacora(),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: SingleChildScrollView(
                            child: _buildProductos(),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(flex: 7, child: _buildBitacora()),
                      ],
                    ),
                  ),
              ],
            ),
          );
          return compact
              ? main
              : Row(
                  children: [
                    _sidebar(),
                    Expanded(child: main),
                  ],
                );
        },
      ),
    ),
  );
}

class _LogHeader extends StatelessWidget {
  const _LogHeader();
  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      color: Color(0xFFEDF3FF),
      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              'EST.',
              style: TextStyle(fontSize: 9, color: Color(0xFF274055)),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'USUARIO',
              style: TextStyle(fontSize: 9, color: Color(0xFF274055)),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'FECHA/HORA',
              style: TextStyle(fontSize: 9, color: Color(0xFF274055)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'ORIGEN',
              style: TextStyle(fontSize: 9, color: Color(0xFF274055)),
            ),
          ),
        ],
      ),
    ),
  );
}

class _LogRow extends StatelessWidget {
  final AccessRecord record;
  const _LogRow({required this.record});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    child: Row(
      children: [
        SizedBox(
          width: 28,
          child: Icon(
            record.exitoso ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: record.exitoso
                ? const Color(0xFF007B57)
                : const Color(0xFFD92020),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            record.usuario.isEmpty ? '(sin usuario)' : record.usuario,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            record.fechaHora.toLocal().toString(),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF274055)),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            record.origen,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF274055)),
          ),
        ),
      ],
    ),
  );
}
