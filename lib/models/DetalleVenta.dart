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
