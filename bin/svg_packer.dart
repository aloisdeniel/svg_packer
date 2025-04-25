import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:svg_packer/svg_packer.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser();
  parser.addOption('name', abbr: 'n', defaultsTo: 'Vector');
  parser.addOption('assetOutput', abbr: 'a');
  parser.addOption('dartOutput', abbr: 'd');
  parser.addOption('dartCollectionName', abbr: 'c');
  parser.addOption('package', abbr: 'k');

  final results = parser.parse(args);

  final input = results.rest.lastOrNull ?? '.';
  final inputDir = Directory(input);
  if (!inputDir.existsSync()) {
    print('Input directory does not exist: $input');
    return;
  }

  final allSvgs = (await inputDir.list().toList())
      .whereType<File>()
      .where((x) => extension(x.path.toLowerCase()) == '.svg')
      .toList();

  if (allSvgs.isEmpty) {
    print('No SVG files found in the directory: $input');
    return;
  }

  final options = PackOptions(
    name: results['name'],
    inputFiles: allSvgs,
    packageName: results['package'],
    assetOutputPath: results['assetOutput'],
    dartOutputPath: results['dartOutput'],
    dataCollectionName: results['dartCollectionName'],
  );
  await pack(options);
}
