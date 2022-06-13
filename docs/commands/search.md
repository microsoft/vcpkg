# vcpkg search

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/commands/search.md).**

## Synopsis

```no-highlight
vcpkg search [options] [query]
```

## Description

Searches for available packages by name and description.

Search performs a case-insensitive search through all available package names and descriptions. The results are displayed in a tabular format.

## Example
```no-highlight
$ vcpkg search zlib
miniz                    2.2.0#1          Single C source file zlib-replacement library
zlib                     1.2.12#1         A compression library
zlib-ng                  2.0.6            zlib replacement with optimizations for 'next generation' systems
```

## Options

All vcpkg commands support a set of [common options](common-options.md).

### `--x-full-desc`

**Experimental and may change or be removed at any time**

Do not truncate long descriptions.

By default, long descriptions will be truncated to keep the tabular output browsable.

[Registries]: ../users/registries.md
