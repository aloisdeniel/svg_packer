import 'package:path/path.dart';
import 'package:recase/recase.dart';
import 'package:svg_packer/src/pack.dart';
import 'package:svg_packer/svg_packer.dart';

String generateDart(SvgPack pack, PackOptions options) {
  final typeName = ReCase(options.name).pascalCase;
  final setTypeName = options.dataCollectionName;
  final assetFileBase = options.assetOutputPath;
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
      TextDecorationColorValue(textConfigId: final strokeId) => 'text$strokeId',
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
    buffer.writeln('class ${themeName}Style extends ${typeName}Style {');
    // Constructor
    buffer.writeln('  const ${themeName}Style({');
    for (var color in instance.colors) {
      final name = getColorName(color);
      buffer.writeln('    this.$name,');
    }
    buffer.writeln('  });');

    // Factory
    buffer.writeln('  factory ${themeName}Style.color(Color color) {');
    buffer.writeln('    return ${themeName}Style(');
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
      buffer.writeln('    /// Default value is ${color.value}');
      buffer.writeln('    final Color? $name;');
    }

    // Values
    buffer.writeln('  @override');
    buffer.writeln('  Map<int, Color> get colors => {');
    for (var color in instance.colors) {
      final name = getColorName(color);
      buffer.writeln('    if($name != null)');
      buffer.writeln('      ${color.offset}: $name!,');
    }
    buffer.writeln('  };');

    buffer.writeln('}');
    return buffer.toString();
  }

  String buildThemeData() {
    final buffer = StringBuffer();
    buffer.writeln('class ${typeName}ThemeData {');
    // Constructor
    buffer.writeln('  const ${typeName}ThemeData({');
    for (var instance in pack.instances) {
      final field = ReCase(instance.name).camelCase;
      buffer.writeln('    this.$field,');
    }
    buffer.writeln('  });');

    // Fields
    for (var instance in pack.instances) {
      final field = ReCase(instance.name).camelCase;
      final themeName = ReCase(instance.name).pascalCase;
      buffer.writeln('    final ${themeName}Style? $field;');
    }

    // getStyle
    buffer.writeln('  ${typeName}Style? getStyle(int id) {');
    buffer.writeln('    return switch(id) {');
    for (var instance in pack.instances) {
      final field = ReCase(instance.name).camelCase;
      buffer.writeln('      ${instance.id} => $field,');
    }
    buffer.writeln('      _ => throw Exception(\'Style not found\'),');
    buffer.writeln('    };');
    buffer.writeln('  }');

    // hashCode
    buffer.writeln('  @override');
    buffer.writeln('  int get hashCode => Object.hashAll([');
    for (var instance in pack.instances) {
      final field = ReCase(instance.name).camelCase;
      buffer.writeln('    $field,');
    }
    buffer.writeln('  ]);');

    // ==
    buffer.writeln('  @override');
    buffer.writeln('  bool operator ==(Object other) {');
    buffer.writeln('    return other is ${typeName}ThemeData &&');
    for (var i = 0; i < pack.instances.length; i++) {
      final instance = pack.instances[i];
      final field = ReCase(instance.name).camelCase;
      buffer.write('      other.$field == $field');
      buffer.writeln(i < pack.instances.length - 1 ? ' &&' : ';');
    }
    buffer.writeln('  }');

    buffer.writeln('}');
    return buffer.toString();
  }

  return '''import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_graphics/vector_graphics.dart';

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

${buildThemeData()}

abstract class ${typeName}Style {
  const ${typeName}Style();
  Map<int, Color> get colors;

  @override
  int get hashCode => Object.hashAll(
        [
          ...colors.entries.map((e) => Object.hash(e.key, e.value)),
        ],
      );

  @override
  bool operator ==(Object other) {
    return other is ${typeName}Style && mapEquals(other.colors, colors);
  }
}

class ${typeName}Theme extends InheritedModel<int> {
  const ${typeName}Theme({
    super.key,
    required this.data,
    required super.child,
  });

  final ${typeName}ThemeData data;

  static ${typeName}Style? of(BuildContext context, ${typeName}Data data) {
    final theme = _of(context, data.id);
    return theme?.getStyle(data.id);
  }

  static ${typeName}ThemeData? _of(BuildContext context, [int? aspect]) {
    return InheritedModel.inheritFrom<${typeName}Theme>(context, aspect: aspect)?.data;
  }

  @override
  bool updateShouldNotify(covariant ${typeName}Theme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  bool updateShouldNotifyDependent(
    covariant ${typeName}Theme oldWidget,
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

class $typeName extends StatelessWidget {
  const $typeName(
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

  final ${typeName}Data data;
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
  final ${typeName}ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    final style = theme != null ? theme!.getStyle(data.id) : ${typeName}Theme.of(context, data);
    return VectorGraphic(
      loader: ${typeName}Loader(data, style: style),
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

class ${typeName}Loader extends BytesLoader {
  const ${typeName}Loader(
    this.data, {
    this.style,
  });

  final ${typeName}Data data;
  final ${typeName}Style? style;

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
    return other is ${typeName}Loader && other.data == data && other.style == style;
  }

  @override
  String toString() => '${typeName}Loader(\${data.name})';
}

${pack.instances.map(generateTheme).join('\n\n')}
''';
}
