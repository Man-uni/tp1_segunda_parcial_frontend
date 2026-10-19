import 'package:flutter/material.dart';
import 'package:tp1_segunda_parcial_frontend/models/DetalleVenta.dart';
import 'package:tp1_segunda_parcial_frontend/models/Venta.dart';
import 'package:tp1_segunda_parcial_frontend/services/VentaService.dart';
import 'package:tp1_segunda_parcial_frontend/utils/format.dart';

class NuevaVentaScreen extends StatefulWidget {
  const NuevaVentaScreen({super.key});

  @override
  State<NuevaVentaScreen> createState() => _NuevaVentaState();
}

class _NuevaVentaState extends State<NuevaVentaScreen> {
  final _service = VentaService();
  late final TextEditingController _ctrlFecha;
  final _ctrlCliente = TextEditingController();
  final _ctrlCant    = TextEditingController();
  final _ctrlDesc    = TextEditingController();
  final _ctrlPrecio  = TextEditingController();
  final List<DetalleVenta> _detalles = [];
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final hoy = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
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

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _agregar() {
    final cant = int.tryParse(_ctrlCant.text);
    final precio = int.tryParse(_ctrlPrecio.text);
    final desc = _ctrlDesc.text.trim();
    if (cant == null || cant <= 0 || precio == null || precio <= 0 || desc.isEmpty) {
      _snack('Cantidad y precio deben ser > 0 y descripcion no vacía');
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
    if (cliente.isEmpty)   { _snack('El cliente no puede estar vacío'); return; }
    if (_detalles.isEmpty) { _snack('Debe agregar al menos un detalle'); return; }
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
      _snack('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva venta'), backgroundColor: const Color(0xFF1B263B),foregroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _ctrlFecha, decoration: const InputDecoration(labelText: 'Fecha', border: OutlineInputBorder()),),
            const SizedBox(height: 12),
            TextField(controller: _ctrlCliente, decoration: const InputDecoration(labelText: 'Cliente', border: OutlineInputBorder()),),
            const SizedBox(height: 8),
            Text('Total: Gs. ${fmtGs(_total)}', style: const TextStyle(fontSize: 16)),
            const Divider(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _ctrlCant,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cant.', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _ctrlDesc,
                    decoration: const InputDecoration(labelText: 'Descripcion', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _ctrlPrecio,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'P. unitario', border: OutlineInputBorder()),
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
            const Text('Detalles agregados:', style: TextStyle(fontWeight: FontWeight.bold)),
            if (_detalles.isNotEmpty) ...[
              const SizedBox(height: 4),
              const Row(
                children: [
                  Expanded(flex: 1, child: Text('Cant',        style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 3, child: Text('Descripcion', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('P.Unit',      style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Total',       style: TextStyle(fontWeight: FontWeight.bold))),
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
                      Expanded(flex: 2, child: Text(fmtGs(d.precioUnitario))),
                      Expanded(flex: 2, child: Text(fmtGs(d.totalDetalle))),
                      IconButton(icon: const Icon(Icons.close, size: 18, color: Colors.red),onPressed: () => setState(() => _detalles.removeAt(i)),
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _guardando ? null : _guardar,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B263B),foregroundColor: Colors.white,),
              child: _guardando
                  ? const SizedBox(height: 20,width: 20,child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Guardar venta'),
            ),
          ],
        ),
      ),
    );
  }
}
