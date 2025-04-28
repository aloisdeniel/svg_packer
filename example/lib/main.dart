import 'package:example/src/widgets/icon.g.dart';
import 'package:flutter/material.dart'
    hide Icons, Icon, IconTheme, IconThemeData, IconData;
import 'package:flutter_svg/svg.dart';

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter SVG Packer Example'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'svg_packer'),
              Tab(text: 'flutter_svg'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SvgPacker(),
            FlutterSvg(),
          ],
        ),
      ),
    );
  }
}

class FlutterSvg extends StatelessWidget {
  const FlutterSvg({super.key});

  String getPath(IconData icon) {
    return 'assets/src/${icon.name}.svg';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            for (final color in [null, Colors.blue, Colors.red]) ...[
              Text(
                color == null
                    ? 'Raw'
                    : 'Color #${color.value.toRadixString(16)}',
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final icon in Icons.values)
                    SvgPicture.asset(
                      getPath(icon),
                      color: color, // Simple color filter
                      height: 64,
                    ),
                ],
              ),
            ],
            Text('Custom theme'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SvgPicture.asset(
                  getPath(Icons.confetti),
                  height: 64,
                ),
                SvgPicture.asset(
                  getPath(Icons.dominos),
                  height: 64,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SvgPacker extends StatelessWidget {
  const SvgPacker({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            for (final color in [null, Colors.blue, Colors.red]) ...[
              Text(
                color == null
                    ? 'Raw'
                    : 'Color #${color.value.toRadixString(16)}',
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final icon in Icons.values)
                    Icon(
                      icon,
                      color: color, // Simple color filter
                      height: 64,
                    ),
                ],
              ),
            ],
            Text('Custom theme'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                Icon(
                  Icons.confetti,
                  height: 64,
                  theme: IconThemeData(
                    // Custom independent colors
                    confetti: ConfettiStyle(
                      fill0: Colors.orange,
                      fill1: Colors.red,
                    ),
                  ),
                ),
                Icon(
                  Icons.dominos,
                  height: 64,
                  theme: IconThemeData(
                    // Custom independent colors
                    dominos: DominosStyle(
                      fill0: Colors.yellow,
                      fill1: Colors.pink,
                      fill2: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
