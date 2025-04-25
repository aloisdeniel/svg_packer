# svg_packer

A tool that packs multiple SVG files into a single binary file.

## Quickstart

Simply put all your svg files in the `assets/src` directory in your package and run the tool :

```sh
dart pub global run svg_packer:<executable>
```

## Comparison

### vector_graphics and vector_graphics_compiler 

* It is just a thin layer on top of vector_graphics and vector_graphics_compiler, it only adds features thanks to code generation
* Generates strongly typed code to reference your files
* Allows to update the colors at runtime (only possible with flutter_svg, which is not optimized)
* Merges all files into a single asset file

### a symbol font

* Symbols in font have a limited number of colors.

### SVG files

* Parsing SVG files can be heavy, even more if you want to generate variations at runtime.
