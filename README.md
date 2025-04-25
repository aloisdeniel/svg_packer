# svg_packer

A tool that packs multiple SVG files into a single binary file.

## Quickstart

Simply put all your svg files in the `assets/src` directory in your package and run the tool:

```sh
dart pub global run svg_packer:svg_packer
```

You should now have a `Vector` widget in `lib/src/widgets/vector.g.dart` to instantiate any of you svg files:

```dart
@override
Widget build(BuildContext context) {
  return Vector(
    Vectors.hello, // compiled from `assets/src/hello.svg`
    theme: VectorThemeData( 
      hello: HelloStyle( // change all individual colors at runtime
        fill0: Colors.red,
        fill1: Colors.blue,
      ),
    ),
    // color: Colors.red, // ...or simply apply a color filter 
  );
}
```


## Comparison

### [vector_graphics](https://github.com/flutter/packages/tree/main/packages/vector_graphics) and [vector_graphics_compiler](https://github.com/flutter/packages/tree/main/packages/vector_graphics_compiler)

* svg_packer is just a thin layer on top of vector_graphics and vector_graphics_compiler, it only adds features thanks to code generation
* svg_packer generates strongly typed code to reference your files
* svg_packer allows to update the colors at runtime (only possible with flutter_svg, which is not optimized)
* svg_packer merges all files into a single asset file that is loaded once for all instances.

### [flutter_svg](https://github.com/flutter/packages/tree/main/third_party/packages/flutter_svg)

* Parsing SVG files can be heavy, even more if you want to generate variations at runtime.
* Not really adapted for icons

### a symbol font

* symbols fonts have a limited number of colors.


