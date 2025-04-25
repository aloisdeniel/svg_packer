import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract class VectorIcons {
  static const VectorIconData icon1 = VectorIconData(0, 'icon1', 0, 0);
}

class Icon1Theme extends VectorIconTheme {
  const Icon1Theme({
    this.fill1,
    this.fill2,
  });

  factory Icon1Theme.color(Color color) {
    return Icon1Theme(
      fill1: color,
      fill2: color.withValues(alpha: color.a * 0.5),
    );
  }

  final Color? fill1;
  final Color? fill2;

  @override
  Map<int, Color> get colorOverride => {
        if (fill1 != null) 24: fill1!,
        if (fill2 != null) 128: fill2!,
      };
}

class VectorIconData {
  const VectorIconData(
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
    return other is VectorIconData && other.id == id;
  }
}

abstract class VectorIconTheme {
  const VectorIconTheme();

  Map<int, Color> get colorOverride;

  @override
  int get hashCode => Object.hashAll([
        ...colorOverride.entries.map((e) => Object.hash(e.key, e.value)),
      ]);

  @override
  bool operator ==(Object other) {
    return other is VectorIconTheme &&
        mapEquals(other.colorOverride, colorOverride);
  }
}

class VectorIcon extends BytesLoader {
  const VectorIcon(
    this.data, {
    this.theme,
  });

  final VectorIconData data;
  final VectorIconTheme? theme;

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
    return other is VectorIcon && other.data == data && other.theme == theme;
  }

  @override
  String toString() => 'VectorIcon(${data.name})';
}
