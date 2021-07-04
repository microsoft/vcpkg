# DEPRECATED: in favor of the `PATCHES` argument to [`vcpkg_from_github()`](vcpkg_from_github.md) et al.

#[===[.md
# vcpkg_apply_patches

Apply a set of patches to a source tree.

```cmake
vcpkg_apply_patches(
    SOURCE_PATH <${SOURCE_PATH}>
    [QUIET]
    PATCHES <patch1.patch>...
)
```
#]===]

function(vcpkg_apply_patches)
    z_vcpkg_deprecation_message("vcpkg_apply_patches has been deprecated in favor of the `PATCHES` argument to `vcpkg_from_*`.")

    cmake_parse_arguments(PARSE_ARGV 0 "arg" "QUIET" "SOURCE_PATH" "PATCHES")

    if(arg_QUIET)
        set(quiet "QUIET")
    else()
        set(quiet)
    endif()

    z_vcpkg_apply_patches(
        SOURCE_PATH "${arg_SOURCE_PATH}"
        ${quiet}
        PATCHES ${arg_PATCHES}
    )
endfunction()
