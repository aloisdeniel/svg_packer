import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_graphics/vector_graphics.dart';

abstract class Icons {
  static const IconData beer = IconData(0, 'beer', 0, 988);
  static const IconData mailVolumeFill =
      IconData(1, 'mailVolumeFill', 988, 448);
  static const IconData dominos = IconData(2, 'dominos', 1436, 843);
  static const IconData flutter = IconData(3, 'flutter', 2280, 156);
  static const IconData flowChart = IconData(4, 'flowChart', 2436, 592);
  static const IconData dart = IconData(5, 'dart', 3028, 428);
  static const IconData apple = IconData(6, 'apple', 3456, 464);
  static const IconData magicFill = IconData(7, 'magicFill', 3920, 568);
  static const List<IconData> values = [
    beer,
    mailVolumeFill,
    dominos,
    flutter,
    flowChart,
    dart,
    apple,
    magicFill,
  ];
}

class IconData {
  const IconData(
    this.id,
    this.name,
    this.offset,
    this.length,
  );

  final int id;
  final String name;
  final int offset;
  final int length;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is IconData && other.id == id;
  }
}

class IconThemeData {
  const IconThemeData({
    this.beer,
    this.mailVolumeFill,
    this.dominos,
    this.flutter,
    this.flowChart,
    this.dart,
    this.apple,
    this.magicFill,
  });
  final BeerStyle? beer;
  final MailVolumeFillStyle? mailVolumeFill;
  final DominosStyle? dominos;
  final FlutterStyle? flutter;
  final FlowChartStyle? flowChart;
  final DartStyle? dart;
  final AppleStyle? apple;
  final MagicFillStyle? magicFill;
  IconStyle? getStyle(int id) {
    return switch (id) {
      0 => beer,
      1 => mailVolumeFill,
      2 => dominos,
      3 => flutter,
      4 => flowChart,
      5 => dart,
      6 => apple,
      7 => magicFill,
      _ => throw Exception('Style not found'),
    };
  }

  @override
  int get hashCode => Object.hashAll([
        beer,
        mailVolumeFill,
        dominos,
        flutter,
        flowChart,
        dart,
        apple,
        magicFill,
      ]);
  @override
  bool operator ==(Object other) {
    return other is IconThemeData &&
        other.beer == beer &&
        other.mailVolumeFill == mailVolumeFill &&
        other.dominos == dominos &&
        other.flutter == flutter &&
        other.flowChart == flowChart &&
        other.dart == dart &&
        other.apple == apple &&
        other.magicFill == magicFill;
  }
}

abstract class IconStyle {
  const IconStyle();
  Map<int, Color> get colors;

  @override
  int get hashCode => Object.hashAll(
        [
          ...colors.entries.map((e) => Object.hash(e.key, e.value)),
        ],
      );

  @override
  bool operator ==(Object other) {
    return other is IconStyle && mapEquals(other.colors, colors);
  }
}

class IconTheme extends InheritedModel<int> {
  const IconTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final IconThemeData data;

  static IconStyle? of(BuildContext context, IconData data) {
    final theme = _of(context, data.id);
    return theme?.getStyle(data.id);
  }

  static IconThemeData? _of(BuildContext context, [int? aspect]) {
    return InheritedModel.inheritFrom<IconTheme>(context, aspect: aspect)?.data;
  }

  @override
  bool updateShouldNotify(covariant IconTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  bool updateShouldNotifyDependent(
    covariant IconTheme oldWidget,
    Set<int> dependencies,
  ) {
    for (var id in dependencies) {
      final newStyle = data.getStyle(id);
      final oldStyle = oldWidget.data.getStyle(id);
      if (!mapEquals(newStyle?.colors, oldStyle?.colors)) {
        return true;
      }
    }
    return false;
  }
}

class Icon extends StatelessWidget {
  const Icon(
    this.data, {
    super.key,
    this.color,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.clipBehavior = Clip.hardEdge,
    this.transitionDuration,
    this.placeholderBuilder,
    this.errorBuilder,
    this.colorFilter,
    this.opacity,
    this.clipViewbox = true,
    this.matchTextDirection = false,
    this.theme,
  });

  final IconData data;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final bool matchTextDirection;
  final String? semanticsLabel;
  final bool excludeFromSemantics;
  final Clip clipBehavior;
  final WidgetBuilder? placeholderBuilder;
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace stackTrace,
  )? errorBuilder;
  final Duration? transitionDuration;
  final ColorFilter? colorFilter;
  final Color? color;
  final Animation<double>? opacity;
  final bool clipViewbox;
  final IconThemeData? theme;

  @override
  Widget build(BuildContext context) {
    final style =
        theme != null ? theme!.getStyle(data.id) : IconTheme.of(context, data);
    return VectorGraphic(
      loader: IconLoader(data, style: style),
      height: height,
      width: width,
      fit: fit,
      alignment: alignment,
      matchTextDirection: matchTextDirection,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      clipBehavior: clipBehavior,
      transitionDuration: transitionDuration,
      placeholderBuilder: placeholderBuilder,
      errorBuilder: errorBuilder,
      opacity: opacity,
      clipViewbox: clipViewbox,
      colorFilter: colorFilter ??
          (color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null),
    );
  }
}

class IconLoader extends BytesLoader {
  const IconLoader(
    this.data, {
    this.style,
  });

  final IconData data;
  final IconStyle? style;

  static ByteData? _packData;
  static String asset = 'assets/vec/icon.vecpack';

  static Future<void> loadPack([BuildContext? context]) async {
    if (_packData == null) {
      final assetBundle =
          context != null ? DefaultAssetBundle.of(context) : rootBundle;
      _packData = await assetBundle.load(asset);
    }
  }

  @override
  Future<ByteData> loadBytes(BuildContext? context) async {
    await loadPack();
    final style = this.style;
    final originalBytes = ByteData.sublistView(
        _packData!, data.offset, data.offset + data.length);
    if (style == null) return originalBytes;
    final bytes = Uint8List.fromList(
        _packData!.buffer.asUint8List(data.offset, data.length));

    int floatToInt8(double x) => (x * 255.0).round() & 0xff;
    for (var override in style.colors.entries) {
      bytes[override.key] = floatToInt8(override.value.b);
      bytes[override.key + 1] = floatToInt8(override.value.g);
      bytes[override.key + 2] = floatToInt8(override.value.r);
      bytes[override.key + 3] = floatToInt8(override.value.a);
    }
    return ByteData.sublistView(bytes).asUnmodifiableView();
  }

  @override
  int get hashCode => Object.hashAll(
        [
          data,
          style,
        ],
      );

  @override
  bool operator ==(Object other) {
    return other is IconLoader && other.data == data && other.style == style;
  }

  @override
  String toString() => 'IconLoader(${data.name})';
}

class BeerStyle extends IconStyle {
  const BeerStyle({
    this.fill0,
  });
  factory BeerStyle.color(Color color) {
    return BeerStyle(
      fill0: color,
    );
  }

  /// Default value is 4278190080
  final Color? fill0;
  @override
  Map<int, Color> get colors => {
        if (fill0 != null) 15: fill0!,
      };
}

class MailVolumeFillStyle extends IconStyle {
  const MailVolumeFillStyle({
    this.fill0,
  });
  factory MailVolumeFillStyle.color(Color color) {
    return MailVolumeFillStyle(
      fill0: color,
    );
  }

  /// Default value is 4278190080
  final Color? fill0;
  @override
  Map<int, Color> get colors => {
        if (fill0 != null) 15: fill0!,
      };
}

class DominosStyle extends IconStyle {
  const DominosStyle({
    this.fill0,
    this.fill1,
    this.fill2,
  });
  factory DominosStyle.color(Color color) {
    return DominosStyle(
      fill0: color,
      fill1: color,
      fill2: color,
    );
  }

  /// Default value is 4294967295
  final Color? fill0;

  /// Default value is 4278215825
  final Color? fill1;

  /// Default value is 4293072951
  final Color? fill2;
  @override
  Map<int, Color> get colors => {
        if (fill0 != null) 15: fill0!,
        if (fill1 != null) 25: fill1!,
        if (fill2 != null) 35: fill2!,
      };
}

class FlutterStyle extends IconStyle {
  const FlutterStyle({
    this.fill0,
  });
  factory FlutterStyle.color(Color color) {
    return FlutterStyle(
      fill0: color,
    );
  }

  /// Default value is 4278190080
  final Color? fill0;
  @override
  Map<int, Color> get colors => {
        if (fill0 != null) 15: fill0!,
      };
}

class FlowChartStyle extends IconStyle {
  const FlowChartStyle({
    this.fill0,
  });
  factory FlowChartStyle.color(Color color) {
    return FlowChartStyle(
      fill0: color,
    );
  }

  /// Default value is 4278190080
  final Color? fill0;
  @override
  Map<int, Color> get colors => {
        if (fill0 != null) 15: fill0!,
      };
}

class DartStyle extends IconStyle {
  const DartStyle({
    this.fill0,
  });
  factory DartStyle.color(Color color) {
    return DartStyle(
      fill0: color,
    );
  }

  /// Default value is 4278190080
  final Color? fill0;
  @override
  Map<int, Color> get colors => {
        if (fill0 != null) 15: fill0!,
      };
}

class AppleStyle extends IconStyle {
  const AppleStyle({
    this.fill0,
  });
  factory AppleStyle.color(Color color) {
    return AppleStyle(
      fill0: color,
    );
  }

  /// Default value is 4278190080
  final Color? fill0;
  @override
  Map<int, Color> get colors => {
        if (fill0 != null) 15: fill0!,
      };
}

class MagicFillStyle extends IconStyle {
  const MagicFillStyle({
    this.fill0,
  });
  factory MagicFillStyle.color(Color color) {
    return MagicFillStyle(
      fill0: color,
    );
  }

  /// Default value is 4278190080
  final Color? fill0;
  @override
  Map<int, Color> get colors => {
        if (fill0 != null) 15: fill0!,
      };
}
