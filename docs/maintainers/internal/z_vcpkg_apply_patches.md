# z_vcpkg_apply_patches

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/).

**Only for internal use in vcpkg helpers. Behavior and arguments will change without notice.**

Apply a set of patches to a source tree.

```cmake
z_vcpkg_apply_patches(
    SOURCE_PATH <path-to-source>
    [QUIET]
    PATCHES <patch>...
)
```

The `<path-to-source>` should be set to `${SOURCE_PATH}` by convention,
and is the path to apply the patches in.

`z_vcpkg_apply_patches` will take the list of `<patch>`es,
which are by default relative to the port directory,
and apply them in order using `git apply`.
Generally, these `<patch>`es take the form of `some.patch`
to select patches in the port directory.
One may also download patches and use `${VCPKG_DOWNLOADS}/path/to/some.patch`.

If `QUIET` is not passed, it is a fatal error for a patch to fail to apply;
otherwise, if `QUIET` is passed, no message is printed.
This should only be used for edge cases, such as patches that are known to fail even on a clean source tree.

## Source
[scripts/cmake/z\_vcpkg\_apply\_patches.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/z_vcpkg_apply_patches.cmake)
