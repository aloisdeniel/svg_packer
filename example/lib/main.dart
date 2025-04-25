import 'package:example/src/widgets/icon.g.dart';
import 'package:flutter/material.dart' hide Icons, Icon;
import 'package:vector_graphics/vector_graphics_compat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter SVG Packer Example'),
      ),
      body: SingleChildScrollView(
        child: Wrap(
          children: [
            for (final icon in Icons.values)
              VectorGraphic(
                loader: Icon(icon),
              ),
          ],
        ),
      ),
    );
  }
}
