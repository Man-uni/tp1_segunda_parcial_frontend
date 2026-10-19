class Producto {
  final int? id;            // NUEVO: lo asigna el servidor
  final String nombre;
  final int precio;
 
  const Producto({this.id, required this.nombre,
      required this.precio});   // cambia: parámetros con nombre
 
  factory Producto.fromJson(Map<String, dynamic> j) {
    return Producto(                // NUEVO: JSON -> objeto
      id: j['id'],
      nombre: j['nombre'],
      precio: (j['precio'] as num).toInt(),
    );
  }
 
  Map<String, dynamic> toJson() => {  // NUEVO: objeto -> JSON
        'nombre': nombre,
        'precio': precio,
      };
}
