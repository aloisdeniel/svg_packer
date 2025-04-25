import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;

sealed class ColorValue {
  const ColorValue(this.offset, this.value);
  final int value;
  final int offset;

  double get alpha {
    return ((value >> 24) & 0xFF) / 255.0;
  }
}

class StrokeColorValue extends ColorValue {
  const StrokeColorValue(
    super.offset,
    super.value,
    this.strokeId,
  );

  final int strokeId;
}

class FillColorValue extends ColorValue {
  const FillColorValue(
    super.offset,
    super.value,
    this.fillId,
  );

  final int fillId;
}

class LinearGradientColorValue extends ColorValue {
  const LinearGradientColorValue(
    super.offset,
    super.value,
    this.gradientId,
    this.stopId,
  );

  final int gradientId;
  final int stopId;
}

class RadialGradientColorValue extends ColorValue {
  const RadialGradientColorValue(
    super.offset,
    super.value,
    this.gradientId,
    this.stopId,
  );

  final int gradientId;
  final int stopId;
}

class TextDecorationColorValue extends ColorValue {
  const TextDecorationColorValue(
    super.offset,
    super.value,
    this.strokeId,
  );

  final int strokeId;
}

class SvgInstance {
  const SvgInstance({
    required this.id,
    required this.source,
    required this.offset,
    required this.length,
    required this.colors,
  });

  final int id;
  final File source;
  final int offset;
  final int length;
  final List<ColorValue> colors;
  String get name {
    return path.basenameWithoutExtension(source.path);
  }
}

class SvgPack {
  const SvgPack({
    required this.instances,
    required this.data,
  });

  final List<SvgInstance> instances;
  final Uint8List data;
}
