import 'package:flutter/material.dart';
import 'package:tp1_segunda_parcial_frontend/models/Venta.dart';
import 'package:tp1_segunda_parcial_frontend/utils/format.dart';

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
            Text('Fecha: ${venta.fecha}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text('Cliente: ${venta.cliente}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text('Total: Gs. ${fmtGs(venta.total)}', style: const TextStyle(fontSize: 16)),
            const Divider(height: 24),
            const Row(
              children: [
                Expanded(flex: 1, child: Text('Cant',        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('Descripcion', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('P.Unit',      style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Total',       style: TextStyle(fontWeight: FontWeight.bold))),
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
                        Expanded(flex: 2, child: Text(fmtGs(d.precioUnitario))),
                        Expanded(flex: 2, child: Text(fmtGs(d.totalDetalle))),
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
