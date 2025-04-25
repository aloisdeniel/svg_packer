import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract class Icons {
  static const IconData beer = IconData(0, 'beer', 0, 988);
  static const IconData mailVolumeFill = IconData(1, 'mailVolumeFill', 988, 448);
  static const IconData flutter = IconData(2, 'flutter', 1436, 156);
  static const IconData flowChart = IconData(3, 'flowChart', 1592, 592);
  static const IconData dart = IconData(4, 'dart', 2184, 428);
  static const IconData apple = IconData(5, 'apple', 2612, 464);
  static const IconData magicFill = IconData(6, 'magicFill', 3076, 568);
  static const List<IconData> values = [
   beer,
   mailVolumeFill,
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

abstract class IconTheme {
  const IconTheme();

  Map<int, Color> get colorOverride;

  @override
  int get hashCode => Object.hashAll([
        ...colorOverride.entries.map((e) => Object.hash(e.key, e.value)),
      ]);

  @override
  bool operator ==(Object other) {
    return other is IconTheme &&
        mapEquals(other.colorOverride, colorOverride);
  }
}

class Icon extends BytesLoader {
  const Icon(
    this.data, {
    this.theme,
  });

  final IconData data;
  final IconTheme? theme;

  static ByteData? _packData;
  static String asset = 'assets/icon.vecpack';

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
    final theme = this.theme;
    final originalBytes = ByteData.sublistView(_packData!);
    if (theme == null) return originalBytes;

    for (var override in theme.colorOverride.entries) {
      int floatToInt8(double x) => (x * 255.0).round() & 0xff;
      final value = floatToInt8(override.value.a) << 24 |
          floatToInt8(override.value.r) << 16 |
          floatToInt8(override.value.g) << 8 |
          floatToInt8(override.value.b) << 0;
      originalBytes.setInt32(override.key, value);
    }
    return originalBytes;
  }

  @override
  int get hashCode => Object.hash(data, theme);

  @override
  bool operator ==(Object other) {
    return other is Icon && other.data == data && other.theme == theme;
  }

  @override
  String toString() => 'Icon(${data.name})';
}

class BeerTheme extends IconTheme {
  const BeerTheme({
    this.fill0,
  });
  factory BeerTheme.color(Color color) {
    return BeerTheme(
      fill0: color,
    );
  }
    final Color? fill0;
  @override
  Map<int, Color> get colorOverride => {
    if(fill0 != null)
      23: fill0!,
  };
}


class MailVolumeFillTheme extends IconTheme {
  const MailVolumeFillTheme({
    this.fill0,
  });
  factory MailVolumeFillTheme.color(Color color) {
    return MailVolumeFillTheme(
      fill0: color,
    );
  }
    final Color? fill0;
  @override
  Map<int, Color> get colorOverride => {
    if(fill0 != null)
      23: fill0!,
  };
}


class FlutterTheme extends IconTheme {
  const FlutterTheme({
    this.fill0,
  });
  factory FlutterTheme.color(Color color) {
    return FlutterTheme(
      fill0: color,
    );
  }
    final Color? fill0;
  @override
  Map<int, Color> get colorOverride => {
    if(fill0 != null)
      23: fill0!,
  };
}


class FlowChartTheme extends IconTheme {
  const FlowChartTheme({
    this.fill0,
  });
  factory FlowChartTheme.color(Color color) {
    return FlowChartTheme(
      fill0: color,
    );
  }
    final Color? fill0;
  @override
  Map<int, Color> get colorOverride => {
    if(fill0 != null)
      23: fill0!,
  };
}


class DartTheme extends IconTheme {
  const DartTheme({
    this.fill0,
  });
  factory DartTheme.color(Color color) {
    return DartTheme(
      fill0: color,
    );
  }
    final Color? fill0;
  @override
  Map<int, Color> get colorOverride => {
    if(fill0 != null)
      23: fill0!,
  };
}


class AppleTheme extends IconTheme {
  const AppleTheme({
    this.fill0,
  });
  factory AppleTheme.color(Color color) {
    return AppleTheme(
      fill0: color,
    );
  }
    final Color? fill0;
  @override
  Map<int, Color> get colorOverride => {
    if(fill0 != null)
      23: fill0!,
  };
}


class MagicFillTheme extends IconTheme {
  const MagicFillTheme({
    this.fill0,
  });
  factory MagicFillTheme.color(Color color) {
    return MagicFillTheme(
      fill0: color,
    );
  }
    final Color? fill0;
  @override
  Map<int, Color> get colorOverride => {
    if(fill0 != null)
      23: fill0!,
  };
}

