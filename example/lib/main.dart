import 'package:example/src/widgets/icon.g.dart';
import 'package:flutter/material.dart'
    hide Icons, Icon, IconTheme, IconThemeData;

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
            for (final color in [null, Colors.blue, Colors.red])
              for (final icon in Icons.values)
                Icon(
                  icon,
                  color: color, // Simple color filter
                  height: 64,
                ),
            Icon(
              Icons.dominos,
              height: 64,
              theme: IconThemeData(
                dominos: DominosStyle(
                  fill0: Colors.yellow,
                  fill1: Colors.pink,
                  fill2: Colors.purple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
