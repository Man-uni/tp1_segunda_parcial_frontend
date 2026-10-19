import 'dart:convert';
import 'package:tp1_segunda_parcial_frontend/models/Productos.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ListaProductos(),
    );
  }
}

class ListaProductos extends StatefulWidget {   // cambia
  const ListaProductos({super.key});
  @override
  State<ListaProductos> createState() => _ListaState();
}
 
class _ListaState extends State<ListaProductos> {
  final _service = ProductoService();    // NUEVO
  List<Producto> _productos = [];        // NUEVO
  bool _cargando = true;                 // NUEVO
  late TextEditingController _filtro;     
 
  @override
  void initState() {                     // NUEVO
    super.initState();
    _filtro = TextEditingController();
    _cargar();
  }
 
  Future<void> _cargar() async {         // NUEVO
    final datos = await _service.listar();
    if (!mounted) return;
    setState(() { _productos = datos; _cargando = false; });
  }

  Future<void> _abrirDetalle([Producto? p]) async {  // NUEVO
    final huboCambio = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (context) => DetalleScreen(producto: p)),
    );
    if (huboCambio == true) _cargar();   // refresca
  }
 
  @override
  Widget build(BuildContext context) {
    final productosFiltrados = _productos.where((p) {
      return p.nombre
          .toLowerCase()
          .startsWith(_filtro.text.toLowerCase()); //coincidencia de las letras en orden
          //contains(_filtro.text.toLowerCase()); //sólo debe contener las letras, no importa el orden
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        backgroundColor: const Color(0xFF1B263B),
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator())   // NUEVO
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                TextField(
                  controller: _filtro,
                  decoration: const InputDecoration(
                      labelText: 'Filtrar por nombre',
                      border: OutlineInputBorder()),
                  onChanged: (value) {
                    setState(() {}); // Actualiza la lista al cambiar el filtro
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: productosFiltrados.length,
                    itemBuilder: (context, i) {
                      final p = productosFiltrados[i];
                      return ListTile(
                        title: Text(p.nombre),
                        subtitle: Text('Gs. ${p.precio}'),
                        onTap: () => _abrirDetalle(p),  // cambia
                      );
                  }),
                ),
              ]),
            ),
      floatingActionButton: FloatingActionButton(  // NUEVO
        onPressed: () => _abrirDetalle(),
        backgroundColor: const Color(0xFF1B263B), 
        foregroundColor: Colors.white,           
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DetalleScreen extends StatefulWidget {
  final Producto? producto;   // cambia: null = producto nuevo
  const DetalleScreen({super.key, this.producto});
  @override
  State<DetalleScreen> createState() => _DetalleState();
}
 
class _DetalleState extends State<DetalleScreen> {
  final _service = ProductoService();
  late final TextEditingController _nombre;
  late final TextEditingController _precio;
  bool get _esNuevo => widget.producto == null;
 
  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(
        text: widget.producto?.nombre ?? '');
    _precio = TextEditingController(
        text: widget.producto?.precio.toString() ?? '');
  }

  Future<void> _guardar() async {
    final p = Producto(
      id: widget.producto?.id,
      nombre: _nombre.text,
      precio: int.tryParse(_precio.text) ?? 0,
    );
    if (_esNuevo) {
      await _service.agregar(p);      // POST
    } else {
      await _service.modificar(p);    // PUT
    }
    if (!mounted) return;
    Navigator.pop(context, true);     // avisa a la lista
  }
 
  Future<void> _eliminar() async {
    await _service.eliminar(widget.producto!.id!);  // DELETE
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esNuevo
            ? 'Nuevo producto' : 'Editar producto'),
        backgroundColor: const Color(0xFF1B263B),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _nombre,
            decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _precio,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Precio (Gs.)',
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
              onPressed: _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B263B), // Fondo azul oscuro
                foregroundColor: Colors.white,            // Texto blanco
              ),
              child: const Text('Guardar'),
          ),
          if (!_esNuevo)
            TextButton(
              onPressed: _eliminar,
              child: const Text('Eliminar',
                  style: TextStyle(color: Colors.red)),
            ),
        ]),
      ),
    );
  }
}

class ProductoService {
  static const _base = 'http://10.0.2.2:4003/productos';
  static const _headers = {'Content-Type': 'application/json'};
  // GET
  Future<List<Producto>> listar() async {
    final r = await http.get(Uri.parse(_base));
    final List datos = jsonDecode(r.body);
    return datos.map((j) => Producto.fromJson(j)).toList();
  }
  // POST
  Future<void> agregar(Producto p) async {
    await http.post(Uri.parse(_base),
          headers: _headers, body: jsonEncode(p.toJson()));
  }
  // PUT /productos/:id
  Future<void> modificar(Producto p) async {
    await http.put(Uri.parse('$_base/${p.id}'),
          headers: _headers, body: jsonEncode(p.toJson()));
  }
  // DELETE /productos/:id
  Future<void> eliminar(int id) async {
    await http.delete(Uri.parse('$_base/$id'));
  }
}
