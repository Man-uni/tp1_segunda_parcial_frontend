import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tp1_segunda_parcial_frontend/models/Venta.dart';

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
