import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';
import 'package:svg_packer/src/pack.dart';
import 'package:svg_packer/svg_packer.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser();
  parser.addOption('name', abbr: 'n', defaultsTo: 'Vector');
  parser.addOption('assetOutput', abbr: 'a', defaultsTo: 'assets/vec');
  parser.addOption('dartOutput', abbr: 'd', defaultsTo: 'lib/src/widgets');
  parser.addOption('dartCollectionName', abbr: 'c', defaultsTo: '<name>s');
  parser.addOption('package', abbr: 'k');

  final results = parser.parse(args);

  final input = results.rest.lastOrNull ?? 'assets/src';
  final inputDir = Directory(input);
  if (!inputDir.existsSync()) {
    print('Input directory does not exist: $input');
    return;
  }

  final allSvgs = (await inputDir.list().toList())
      .whereType<File>()
      .where((x) => path.extension(x.path.toLowerCase()) == '.svg')
      .toList();

  if (allSvgs.isEmpty) {
    print('No SVG files found in the directory: $input');
    return;
  }

  final name = results['name'].toString();
  final fileBasename = ReCase(name).snakeCase;
  final dartOutputPath = results['dartOutput'].toString();
  final assetOutputPath = results['assetOutput'].toString();
  final options = PackOptions(
    name: name,
    inputFiles: allSvgs,
    packageName: results['package'],
    assetOutputPath: assetOutputPath.endsWith('.vecpack')
        ? assetOutputPath
        : path.join(assetOutputPath, '$fileBasename.vecpack'),
    dartOutputPath: dartOutputPath.endsWith('.dart')
        ? dartOutputPath
        : path.join(dartOutputPath, '$fileBasename.g.dart'),
    dataCollectionName:
        results['dartCollectionName'].toString().replaceAll('<name>', name),
  );

  ansiColorDisabled = false;

  print('');
  print('███ SVG_PACKER ');

  final block = AnsiPen()..white();

  print('');
  print('${block('▒▒')} Configuration');
  final key = AnsiPen()..white();
  final value = AnsiPen()..white(bold: true);
  final inValue = AnsiPen()..cyan(bold: true);
  final outValue = AnsiPen()..green(bold: true);
  print('');
  print(' ${key('Name:')}');
  print('  ${inValue('▎${options.name} ')}');

  if (options.packageName != null) {
    print('');
    print('  ${key('Package name:')}');
    print('   ${inValue('▎${options.packageName ?? ''}')}');
  }
  print('');
  print(' ${key('Dart output path:')}');
  print('  ${inValue('▎${options.dartOutputPath}')}');

  print('');
  print(' ${key('Asset output path:')}');
  print('  ${inValue('▎${options.assetOutputPath}')}');

  print('');
  print(' ${key('Input files:')}');
  const maxDisplayed = 10;
  for (var file in options.inputFiles.take(maxDisplayed - 1)) {
    print('  ${inValue('▎${file.path}')}');
  }
  var other = options.inputFiles.length - (maxDisplayed - 1);
  if (other > 1) {
    print('  ${inValue('▎+$other files')}');
  } else if (other == 1) {
    final file = options.inputFiles.last;
    print('  ${inValue('▎${file.path}')}');
  }

  print('');
  print('');
  print('${block('▒▒')} Packing is about to start...');
  print('');
  final result = await pack(options);

  final success = AnsiPen()..green(bold: true);
  print('');
  print(success('▒▒ Packing completed!'));

  print('');
  print(' ${key('Asset:')}');
  print('  ${outValue('▎${options.assetOutputPath} ')}');
  print(
      '  ${outValue('▎${result.data.length} bytes (${(100.0 * result.originalSize / result.data.length.toDouble()).toStringAsFixed(2)}% compression)')}');

  print('');
  print(' ${key('Resources:')}');
  void printResource(SvgInstance instance) {
    var colors = '';
    if (instance.colors.isNotEmpty) {
      colors = ' (${instance.colors.length} colors)';
    }
    print(
        '  ${outValue('▎${options.dataCollectionName}.${instance.name}$colors ${instance.length} bytes')}');
  }

  for (var file in result.instances.take(maxDisplayed - 1)) {
    printResource(file);
  }

  other = result.instances.length - (maxDisplayed - 1);
  if (other > 1) {
    print('  ${outValue('▎+$other resources')}');
  } else if (other == 1) {
    final file = result.instances.last;
    printResource(file);
  }
}
