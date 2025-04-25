import 'package:path/path.dart';
import 'package:recase/recase.dart';
import 'package:svg_packer/src/pack.dart';
import 'package:svg_packer/svg_packer.dart';

String generateDart(SvgPack pack, PackOptions options) {
  final typeName = ReCase(options.name).pascalCase;
  final setTypeName = options.dataCollectionName ?? ('${typeName}s');
  final fileBasename = ReCase(options.name).snakeCase;
  final assetFileBase =
      options.assetOutputPath ?? 'assets/$fileBasename.vecpack';
  final assetFile = options.packageName != null
      ? join(
          'packages/${options.packageName!}',
          assetFileBase,
        )
      : assetFileBase;

  String getColorName(ColorValue color) {
    return switch (color) {
      FillColorValue(fillId: final fillId) => 'fill$fillId',
      StrokeColorValue(strokeId: final strokeId) => 'stroke$strokeId',
      LinearGradientColorValue(
        gradientId: final gradientId,
        stopId: final stopId
      ) =>
        'linear${gradientId}c$stopId',
      RadialGradientColorValue(
        gradientId: final gradientId,
        stopId: final stopId
      ) =>
        'radial${gradientId}c$stopId',
      TextDecorationColorValue(strokeId: final strokeId) => 'text$strokeId',
    };
  }

  String generateCollection() {
    final buffer = StringBuffer();
    buffer.writeln('abstract class $setTypeName {');
    for (var instance in pack.instances) {
      final field = ReCase(instance.name).camelCase;
      buffer.writeln(
          '  static const ${typeName}Data $field = ${typeName}Data(${instance.id}, \'$field\', ${instance.offset}, ${instance.length});');
    }

    buffer.writeln('  static const List<${typeName}Data> values = [');
    for (var instance in pack.instances) {
      final field = ReCase(instance.name).camelCase;
      buffer.writeln('   $field,');
    }
    buffer.writeln('  ];');

    buffer.writeln('}');
    return buffer.toString();
  }

  String generateTheme(SvgInstance instance) {
    final themeName = ReCase(instance.name).pascalCase;
    final buffer = StringBuffer();
    buffer.writeln('class ${themeName}Theme extends ${typeName}Theme {');
    // Constructor
    buffer.writeln('  const ${themeName}Theme({');
    for (var color in instance.colors) {
      final name = getColorName(color);
      buffer.writeln('    this.$name,');
    }
    buffer.writeln('  });');

    // Factory
    buffer.writeln('  factory ${themeName}Theme.color(Color color) {');
    buffer.writeln('    return ${themeName}Theme(');
    for (var color in instance.colors) {
      final name = getColorName(color);
      final alpha = color.alpha == 1
          ? ''
          : '.withValues(alpha: color.a * ${color.alpha.toStringAsFixed(2)})';
      buffer.writeln('      $name: color$alpha,');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    // Fields
    for (var color in instance.colors) {
      final name = getColorName(color);
      buffer.writeln('    final Color? $name;');
    }

    // Values
    buffer.writeln('  @override');
    buffer.writeln('  Map<int, Color> get colorOverride => {');
    for (var color in instance.colors) {
      final name = getColorName(color);
      buffer.writeln('    if($name != null)');
      buffer.writeln('      ${color.offset}: $name!,');
    }
    buffer.writeln('  };');

    buffer.writeln('}');
    return buffer.toString();
  }

  return '''import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

${generateCollection()}

class ${typeName}Data {
  const ${typeName}Data(
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
    return other is ${typeName}Data && other.id == id;
  }
}

abstract class ${typeName}Theme {
  const ${typeName}Theme();

  Map<int, Color> get colorOverride;

  @override
  int get hashCode => Object.hashAll([
        ...colorOverride.entries.map((e) => Object.hash(e.key, e.value)),
      ]);

  @override
  bool operator ==(Object other) {
    return other is ${typeName}Theme &&
        mapEquals(other.colorOverride, colorOverride);
  }
}

class $typeName extends BytesLoader {
  const $typeName(
    this.data, {
    this.theme,
  });

  final ${typeName}Data data;
  final ${typeName}Theme? theme;

  static ByteData? _packData;
  static String asset = '$assetFile';

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
    return other is $typeName && other.data == data && other.theme == theme;
  }

  @override
  String toString() => '$typeName(\${data.name})';
}

${pack.instances.map(generateTheme).join('\n\n')}
''';
}
