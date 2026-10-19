import 'package:tp1_segunda_parcial_frontend/models/DetalleVenta.dart';

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
