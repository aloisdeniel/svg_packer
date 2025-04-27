import 'dart:io';
import 'dart:typed_data';

import 'package:svg_packer/src/color_reader.dart';
import 'package:svg_packer/src/pack.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

class SvgPacker {
  /// Compiles all SVG files in the given list into a single binary blob.
  Future<SvgPack> pack(
    List<File> svgFiles, {
    bool enableMaskingOptimizer = true,
    bool enableClippingOptimizer = true,
    bool enableOverdrawOptimizer = true,
    bool warningsAsErrors = false,
    bool useHalfPrecisionControlPoints = false,
  }) async {
    if (enableMaskingOptimizer ||
        enableClippingOptimizer ||
        enableOverdrawOptimizer) {
      initializeTessellatorFromFlutterCache();
      initializePathOpsFromFlutterCache();
    }
    final effectiveFiles =
        svgFiles.where((x) => x.path.toLowerCase().endsWith('.svg')).toList();
    final instances = <SvgInstance>[];
    final data = <int>[];
    for (var i = 0; i < effectiveFiles.length; i++) {
      final element = effectiveFiles[i];
      final svg = await element.readAsString();
      final encoded = encodeSvg(
        xml: svg,
        debugName: element.path,
        enableMaskingOptimizer: enableMaskingOptimizer,
        enableClippingOptimizer: enableClippingOptimizer,
        enableOverdrawOptimizer: enableOverdrawOptimizer,
        warningsAsErrors: warningsAsErrors,
        useHalfPrecisionControlPoints: useHalfPrecisionControlPoints,
      );
      final colors = SvgColorReader().read(ByteData.sublistView(encoded));

      instances.add(
        SvgInstance(
          id: i,
          source: element,
          offset: data.length,
          length: encoded.lengthInBytes,
          colors: colors,
        ),
      );
      data.addAll(encoded);

      // Align
      final int mod = data.length % 4;
      if (mod != 0) {
        data.addAll(_zeroBuffer.take(4 - mod));
      }
    }

    return SvgPack(
      instances: instances,
      data: Uint8List.fromList(data),
    );
  }

  static final Uint8List _zeroBuffer = Uint8List(8);
}
