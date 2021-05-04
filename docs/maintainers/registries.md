# Creating Registries

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/maintainers/registries.md).**

There are two parts to using registries; this documents the creation side of
the relationship. In order to learn more about using registries that others
have created, please read [this documentation](../users/registries.md).

## Table of Contents

- [Creating Registries](#creating-registries)
  - [Table of Contents](#table-of-contents)
  - [Layout of Registries](#layout-of-registries)
    - [Version Objects](#version-objects)
      - [Version Objects: location field](#version-objects-location-field)
      - [Version Objects: version field](#version-objects-version-field)
  - [Adding Versions to a Registry](#adding-versions-to-a-registry)
    - [Git Registries](#git-registries)
    - [Filesystem Registries](#filesystem-registries)
  - [Registry Requirements](#registry-requirements)

## Layout of Registries

All registries must have at least a `versions` directory, with a
`baseline.json` inside it. This file contains the set of "latest versions",
as well as past sets of "latest versions" in the case of the filesystem
registry.

The `versions` directory contains all the information about which versions of
which packages are contained in the registry, along with where those versions
are stored. The rest of the registry just acts as a backing store, as far as
vcpkg is concerned: only things inside the `versions` directory will be used
to direct how your registry is seen by vcpkg.

Each port in a registry should exist in the versions directory as
`<first letter of port>-/<name of port>.json`; in other words, the
information about the `kitten` port would be located in
`versions/k-/kitten.json`. This should be a top-level object with only a
single field: `"versions"`. This field should contain an array of version 
objects.

### Version Objects

A version object contains information on how to find a specific version of a
port. It contains a version field, the `"port-version"` field, and finally
the location of the files in the backing store (which is different depending
on what kind of registry one has).

#### Version Objects: location field

The location field can be one of two things, depending on the type of 
registry:

- The built-in registry, and git registries generally, use the `"git-tree"`
  field, which is a git tree; in other words, what you get when you write
  `git rev-parse COMMIT-ID:PATH-TO-PORT`.
- Filesystem registries use a path rooted from the base directory; it should
  look something like `"$/path/to/port/dir`"

#### Version Objects: version field

The version fields of a version object should be the same as the version
fields from the `vcpkg.json` of the port that this refers to. When the
underlying port uses `"version-string"`, use `"version-string"`; when the
underlying port uses `"version"`, use `"version"`, and etc. The value of this
field must also be exactly the same as the `vcpkg.json`. `"port-version"`
should similarly be exactly the same, noting that not specifying
`"port-version"` is the same as it being `0`.

As a special case, all `CONTROL` files have version kind `"version-string"`.

## Adding Versions to a Registry

### Git Registries

### Filesystem Registries

## Registry Requirements