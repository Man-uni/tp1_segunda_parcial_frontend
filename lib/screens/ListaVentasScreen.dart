import 'package:flutter/material.dart';
import 'package:tp1_segunda_parcial_frontend/models/Venta.dart';
import 'package:tp1_segunda_parcial_frontend/screens/DetalleVentaScreen.dart';
import 'package:tp1_segunda_parcial_frontend/screens/NuevaVentaScreen.dart';
import 'package:tp1_segunda_parcial_frontend/services/VentaService.dart';
import 'package:tp1_segunda_parcial_frontend/utils/format.dart';

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
    final guardado = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const NuevaVentaScreen()),);
    if (guardado == true) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ventas'), backgroundColor: const Color(0xFF1B263B),foregroundColor: Colors.white,),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _ventas.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final v = _ventas[i];
                return ListTile(
                  title: Text(v.fecha),
                  subtitle: Text(v.cliente),
                  trailing: Text('Gs. ${fmtGs(v.total)}'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetalleVentaScreen(venta: v)),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirNuevaVenta, backgroundColor: const Color(0xFF1B263B), foregroundColor: Colors.white, child: const Icon(Icons.add),),
    );
  }
}
