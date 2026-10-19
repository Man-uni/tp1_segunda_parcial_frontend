import 'package:flutter/material.dart';
import 'package:tp1_segunda_parcial_frontend/screens/ListaVentasScreen.dart';

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
