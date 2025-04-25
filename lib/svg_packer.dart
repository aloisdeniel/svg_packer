import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';
import 'package:svg_packer/src/generators/dart.dart';
import 'package:svg_packer/src/packer.dart';

class PackOptions {
  PackOptions({
    required this.name,
    required this.inputFiles,
    this.packageName,
    this.assetOutputPath,
    this.dartOutputPath,
    this.dataCollectionName,
  });

  /// The base name for the generated dart code and asset file.
  final String name;

  /// Name of the generated data collection.
  final String? dataCollectionName;

  /// Asset output path for the generated asset file.
  final String? assetOutputPath;

  /// Dart output path for the generated dart code.
  final String? dartOutputPath;

  /// Package name for the asset path read from the dart code.
  final String? packageName;

  /// List of SVG files to be packed.
  final List<File> inputFiles;
}

/// Pack all SVG files into a single asset and its associated Dart code.
Future<void> pack(PackOptions options) async {
  final packer = SvgPacker();
  final pack = await packer.pack(options.inputFiles);

  final fileBasename = ReCase(options.name).snakeCase;

  // Asset
  final assetFile =
      File(options.assetOutputPath ?? 'assets/$fileBasename.vecpack');
  final assetDir = Directory(path.dirname(assetFile.path));
  if (!assetDir.existsSync()) {
    await assetDir.create(recursive: true);
  }
  await assetFile.writeAsBytes(pack.data);

  // Dart
  final dartOutput = generateDart(pack, options);
  final dartFile =
      File(options.dartOutputPath ?? 'lib/src/widgets/$fileBasename.g.dart');
  final dartDir = Directory(path.dirname(dartFile.path));
  if (!dartDir.existsSync()) {
    await dartDir.create(recursive: true);
  }

  await dartFile.writeAsString(dartOutput);
}
