import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';
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
  await pack(options);
}
