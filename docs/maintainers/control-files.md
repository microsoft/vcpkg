# CONTROL files

Each port has some static metadata in the form of a `CONTROL` file. This file uses the same syntax and a subset of the fields from [the Debian `control` format][debian].

Field names are case-sensitive.

[debian]: https://www.debian.org/doc/debian-policy/ch-controlfields.html

## Source Paragraph

The first paragraph appearing in a `CONTROL` file is the Source paragraph, which defines the core attributes of the package (name, version, and so on).

### Example:
```no-highlight
Source: vtk
Version: 8.1.0-1
Description: Software system for 3D computer graphics, image processing, and visualization
Build-Depends: zlib, libpng, tiff, libxml2, jsoncpp, glew, freetype
```

### Recognized fields

#### Source
The name of the port.

#### Version
The port version.

This field should be an alphanumeric string which may also contain `.`, `_`, or `-`. No attempt at ordering versions is made; all versions are treated as bitstrings and are only evaluated for equality.

By convention, if a portfile is modified without incrementing the "upstream" version, a `-#` is appended to create a unique version string.

Example:
```no-highlight
Version: 1.0.5-2
```

#### Description
A description of the library

The first sentence of the description should concisely describe the purpose and contents of the library. Then, a larger description including the library's "proper name" should follow.

#### Maintainer
Reserved for future use.

#### Build-Depends
The list of dependencies required to build and use this library.

Example:
```no-highlight
Build-Depends: zlib, libpng, libjpeg-turbo, tiff
```

Unlike dpkg, Vcpkg does not distinguish between build-only dependencies and runtime dependencies. The complete list of dependencies needed to successfully use the library should be specified.

*For example: websocketpp is a header only library, and thus does not require any dependencies at install time. However, downstream users need boost and openssl to make use of the library. Therefore, websocketpp lists boost and openssl as dependencies*

Dependencies can be filtered based on the target triplet to support different requirements on Windows Desktop versus the Universal Windows Platform. Currently, the string inside parentheses is substring-compared against the triplet name. __This will change in a future version to not depend on the triplet name.__

Example:
```no-highlight
Build-Depends: zlib (windows), openssl (windows), boost (windows), websocketpp (windows)
```

## Feature Paragraphs

After the Source Paragraph, `CONTROL` files can list zero or more Feature Paragraphs which declare features.

### Example:
```no-highlight
Source: vtk
Version: 8.1.0-1
Description: Software system for 3D computer graphics, image processing, and visualization
Build-Depends: zlib, libpng, tiff, libxml2, jsoncpp, glew, freetype

Feature: mpi
Description: MPI functionality for VTK
Build-Depends: msmpi, hdf5[parallel]
```

### Recognized fields

#### Feature
The name of the feature.

#### Description
A description of the feature

#### Build-Depends
The list of dependencies required to build and use this feature.

All dependencies from selected features are unioned together to produce the final dependency set for the build. This field follows the same syntax as `Build-Depends` in the Source Paragraph.
