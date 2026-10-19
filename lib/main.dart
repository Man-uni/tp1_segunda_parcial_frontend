import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ListaVentasScreen());
  }
}

// ── Modelos ──────────────────────────────────────────

class DetalleVenta {
  final int cantidad;
  final String descripcion;
  final int precioUnitario;
  final int totalDetalle;

  const DetalleVenta({
    required this.cantidad,
    required this.descripcion,
    required this.precioUnitario,
    required this.totalDetalle,
  });

  factory DetalleVenta.fromJson(Map<String, dynamic> j) => DetalleVenta(
        cantidad: (j['cantidad'] as num).toInt(),
        descripcion: j['descripcion'],
        precioUnitario: (j['precio_unitario'] as num).toInt(),
        totalDetalle: (j['total_detalle'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'cantidad': cantidad,
        'descripcion': descripcion,
        'precio_unitario': precioUnitario,
        'total_detalle': totalDetalle,
      };
}

class Venta {
  final int? id;
  final String fecha;
  final String cliente;
  final int total;
  final List<DetalleVenta> detalles;

  const Venta({
    this.id,
    required this.fecha,
    required this.cliente,
    required this.total,
    required this.detalles,
  });

  factory Venta.fromJson(Map<String, dynamic> j) => Venta(
        id: j['id'],
        fecha: j['fecha'],
        cliente: j['cliente'],
        total: (j['total'] as num).toInt(),
        detalles: (j['detalles'] as List)
            .map((d) => DetalleVenta.fromJson(d))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'fecha': fecha,
        'cliente': cliente,
        'total': total,
        'detalles': detalles.map((d) => d.toJson()).toList(),
      };
}

// ── Servicio ─────────────────────────────────────────

class VentaService {
  static const _base = 'http://localhost:4002/ventas';
  static const _headers = {'Content-Type': 'application/json'};

  Future<List<Venta>> listar() async {
    final r = await http.get(Uri.parse(_base));
    final List datos = jsonDecode(r.body);
    return datos.map((j) => Venta.fromJson(j)).toList();
  }

  Future<Venta> agregar(Venta v) async {
    final r = await http.post(
      Uri.parse(_base),
      headers: _headers,
      body: jsonEncode(v.toJson()),
    );
    if (r.statusCode == 201) return Venta.fromJson(jsonDecode(r.body));
    throw Exception('Error ${r.statusCode}');
  }
}

// ── Pantalla 1: Listado de ventas ─────────────────────

class ListaVentasScreen extends StatefulWidget {
  const ListaVentasScreen({super.key});

  @override
  State<ListaVentasScreen> createState() => _ListaVentasState();
}

class _ListaVentasState extends State<ListaVentasScreen> {
  final _service = VentaService();
  List<Venta> _ventas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final datos = await _service.listar();
    if (!mounted) return;
    setState(() {
      _ventas = datos;
      _cargando = false;
    });
  }

  Future<void> _abrirNuevaVenta() async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NuevaVentaScreen()),
    );
    if (guardado == true) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
        backgroundColor: const Color(0xFF1B263B),
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _ventas.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final v = _ventas[i];
                return ListTile(
                  title: Text(v.fecha),
                  subtitle: Text(v.cliente),
                  trailing: Text('Gs. ${_fmtGs(v.total)}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DetalleVentaScreen(venta: v)),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirNuevaVenta,
        backgroundColor: const Color(0xFF1B263B),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ── Pantalla 2: Detalle de venta ──────────────────────

class DetalleVentaScreen extends StatelessWidget {
  final Venta venta;
  const DetalleVentaScreen({super.key, required this.venta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Venta #${venta.id}'),
        backgroundColor: const Color(0xFF1B263B),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fecha: ${venta.fecha}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text('Cliente: ${venta.cliente}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text('Total: Gs. ${_fmtGs(venta.total)}',
                style: const TextStyle(fontSize: 16)),
            const Divider(height: 24),
            const Row(
              children: [
                Expanded(flex: 1, child: Text('Cant', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('Descripcion', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('P.Unit', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const Divider(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: venta.detalles.length,
                itemBuilder: (context, i) {
                  final d = venta.detalles[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: Text('${d.cantidad}')),
                        Expanded(flex: 3, child: Text(d.descripcion)),
                        Expanded(flex: 2, child: Text(_fmtGs(d.precioUnitario))),
                        Expanded(flex: 2, child: Text(_fmtGs(d.totalDetalle))),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pantalla 3: Nueva venta ───────────────────────────

class NuevaVentaScreen extends StatefulWidget {
  const NuevaVentaScreen({super.key});

  @override
  State<NuevaVentaScreen> createState() => _NuevaVentaState();
}

class _NuevaVentaState extends State<NuevaVentaScreen> {
  final _service = VentaService();
  late final TextEditingController _ctrlFecha;
  final _ctrlCliente = TextEditingController();
  final _ctrlCant = TextEditingController();
  final _ctrlDesc = TextEditingController();
  final _ctrlPrecio = TextEditingController();
  final List<DetalleVenta> _detalles = [];
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final hoy =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    _ctrlFecha = TextEditingController(text: hoy);
  }

  @override
  void dispose() {
    _ctrlFecha.dispose();
    _ctrlCliente.dispose();
    _ctrlCant.dispose();
    _ctrlDesc.dispose();
    _ctrlPrecio.dispose();
    super.dispose();
  }

  int get _total => _detalles.fold(0, (s, d) => s + d.totalDetalle);

  void _agregar() {
    final cant = int.tryParse(_ctrlCant.text);
    final precio = int.tryParse(_ctrlPrecio.text);
    final desc = _ctrlDesc.text.trim();
    if (cant == null || cant <= 0 || precio == null || precio <= 0 || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Cantidad y precio deben ser > 0 y descripcion no vacía')),
      );
      return;
    }
    setState(() {
      _detalles.add(DetalleVenta(
        cantidad: cant,
        descripcion: desc,
        precioUnitario: precio,
        totalDetalle: cant * precio,
      ));
      _ctrlCant.clear();
      _ctrlDesc.clear();
      _ctrlPrecio.clear();
    });
  }

  Future<void> _guardar() async {
    final cliente = _ctrlCliente.text.trim();
    if (cliente.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El cliente no puede estar vacío')),
      );
      return;
    }
    if (_detalles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe agregar al menos un detalle')),
      );
      return;
    }
    setState(() => _guardando = true);
    try {
      await _service.agregar(Venta(
        fecha: _ctrlFecha.text.trim(),
        cliente: cliente,
        total: _total,
        detalles: List.unmodifiable(_detalles),
      ));
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva venta'),
        backgroundColor: const Color(0xFF1B263B),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera
            TextField(
              controller: _ctrlFecha,
              decoration: const InputDecoration(
                  labelText: 'Fecha', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrlCliente,
              decoration: const InputDecoration(
                  labelText: 'Cliente', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            Text('Total: Gs. ${_fmtGs(_total)}',
                style: const TextStyle(fontSize: 16)),
            const Divider(height: 20),
            // Bloque agregar detalle
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _ctrlCant,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Cant.', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _ctrlDesc,
                    decoration: const InputDecoration(
                        labelText: 'Descripcion',
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _ctrlPrecio,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'P. unitario',
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  onPressed: _agregar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B263B),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Detalles agregados:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            if (_detalles.isNotEmpty) ...[
              const SizedBox(height: 4),
              const Row(
                children: [
                  Expanded(flex: 1, child: Text('Cant', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 3, child: Text('Descripcion', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('P.Unit', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 36),
                ],
              ),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: _detalles.length,
                itemBuilder: (context, i) {
                  final d = _detalles[i];
                  return Row(
                    children: [
                      Expanded(flex: 1, child: Text('${d.cantidad}')),
                      Expanded(flex: 3, child: Text(d.descripcion)),
                      Expanded(flex: 2, child: Text(_fmtGs(d.precioUnitario))),
                      Expanded(flex: 2, child: Text(_fmtGs(d.totalDetalle))),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18, color: Colors.red),
                        onPressed: () =>
                            setState(() => _detalles.removeAt(i)),
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _guardando ? null : _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B263B),
                foregroundColor: Colors.white,
              ),
              child: _guardando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Guardar venta'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Utilidad ──────────────────────────────────────────

String _fmtGs(int valor) {
  final s = valor.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}
