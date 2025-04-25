import 'dart:typed_data';

import 'package:svg_packer/src/codec.dart';
import 'package:svg_packer/src/pack.dart';

// Extracts all color references from a vector graphics.
class SvgColorReader extends VectorGraphicsCodecListener {
  List<ColorValue> colors = [];
  int _offset = 0;

  List<ColorValue> read(ByteData data) {
    colors.clear();
    final codec = VectorGraphicsCodec();
    codec.decode(data, this);
    return colors;
  }

  @override
  void onCommandBegin(int offset) {
    _offset = offset;
  }

  @override
  void onPaintObject({
    required int color,
    required int? strokeCap,
    required int? strokeJoin,
    required int blendMode,
    required double? strokeMiterLimit,
    required double? strokeWidth,
    required int paintStyle,
    required int id,
    required int? shaderId,
  }) {
    final offset = _offset + 8;
    if (paintStyle == 1) {
      colors.add(StrokeColorValue(offset, color, id));
    } else {
      colors.add(FillColorValue(offset, color, id));
    }
  }

  @override
  void onLinearGradient(
    double fromX,
    double fromY,
    double toX,
    double toY,
    Int32List colors,
    Float32List? offsets,
    int tileMode,
    int id,
  ) {
    final offset = _offset + 16 + 32 * 4 + 16;
    for (var i = 0; i < colors.length; i++) {
      final color = colors[i];
      this.colors.add(LinearGradientColorValue(offset + i * 32, color, id, i));
    }
  }

  @override
  void onRadialGradient(
      double centerX,
      double centerY,
      double radius,
      double? focalX,
      double? focalY,
      Int32List colors,
      Float32List? offsets,
      Float64List? transform,
      int tileMode,
      int id) {
    final offset = _offset + 16 + 32 * 3 + 8 + (focalX != null ? 32 * 2 : 0);
    for (var i = 0; i < colors.length; i++) {
      final color = colors[i];
      this.colors.add(LinearGradientColorValue(offset + i * 32, color, id, i));
    }
  }

  @override
  void onTextConfig(
      String text,
      String? fontFamily,
      double xAnchorMultiplier,
      int fontWeight,
      double fontSize,
      int decoration,
      int decorationStyle,
      int decorationColor,
      int id) {
    final offset = _offset + 8;
    colors.add(StrokeColorValue(offset, decorationColor, id));
  }

  @override
  void onClipPath(int pathId) {}

  @override
  void onDrawImage(int imageId, double x, double y, double width, double height,
      Float64List? transform) {}

  @override
  void onDrawPath(int pathId, int? paintId, int? patternId) {}

  @override
  void onDrawText(int textId, int? fillId, int? strokeId, int? patternId) {}

  @override
  void onDrawVertices(
      Float32List vertices, Uint16List? indices, int? paintId) {}

  @override
  void onImage(int imageId, int format, Uint8List data,
      {VectorGraphicsErrorListener? onError}) {}

  @override
  void onMask() {}

  @override
  void onPathClose() {}

  @override
  void onPathCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {}

  @override
  void onPathFinished() {}

  @override
  void onPathLineTo(double x, double y) {}

  @override
  void onPathMoveTo(double x, double y) {}

  @override
  void onPathStart(int id, int fillType) {}

  @override
  void onPatternStart(int patternId, double x, double y, double width,
      double height, Float64List transform) {}

  @override
  void onRestoreLayer() {}

  @override
  void onSaveLayer(int paintId) {}

  @override
  void onSize(double width, double height) {}

  @override
  void onTextPosition(int textPositionId, double? x, double? y, double? dx,
      double? dy, bool reset, Float64List? transform) {}

  @override
  void onUpdateTextPosition(int textPositionId) {}
}
