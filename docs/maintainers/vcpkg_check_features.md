# vcpkg_check_features

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_check_features.md).
Check if one or more features are a part of a package installation.

```cmake
vcpkg_check_features(
    OUT_FEATURE_OPTIONS <out-var>
    [PREFIX <prefix>]
    [FEATURES
        [<feature-name> <feature-var>]...
        ]
    [INVERTED_FEATURES
        [<feature-name> <feature-var>]...
        ]
)
```

The `<out-var>` should be set to `FEATURE_OPTIONS` by convention.

`vcpkg_check_features()` will:

- for each `<feature-name>` passed in `FEATURES`:
    - if the feature is set, add `-D<feature-var>=ON` to `<out-var>`,
      and set `<prefix>_<feature-var>` to ON.
    - if the feature is not set, add `-D<feature-var>=OFF` to `<out-var>`,
      and set `<prefix>_<feature-var>` to OFF.
- for each `<feature-name>` passed in `INVERTED_FEATURES`:
    - if the feature is set, add `-D<feature-var>=OFF` to `<out-var>`,
      and set `<prefix>_<feature-var>` to OFF.
    - if the feature is not set, add `-D<feature-var>=ON` to `<out-var>`,
      and set `<prefix>_<feature-var>` to ON.

If `<prefix>` is not passed, then the feature vars set are simply `<feature-var>`,
not `_<feature-var>`.

If `INVERTED_FEATURES` is not passed, then the `FEATURES` keyword is optional.
This behavior is deprecated.

If the same `<feature-var>` is passed multiple times,
then `vcpkg_check_features` will cause a fatal error,
since that is a bug.

## Examples

### Example 1: Regular features

```cmake
$ ./vcpkg install mimalloc[asm,secure]

# ports/mimalloc/portfile.cmake
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        asm       MI_SEE_ASM
        override  MI_OVERRIDE
        secure    MI_SECURE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        # Expands to "-DMI_SEE_ASM=ON;-DMI_OVERRIDE=OFF;-DMI_SECURE=ON"
        ${FEATURE_OPTIONS}
)
```

### Example 2: Inverted features

```cmake
$ ./vcpkg install cpprestsdk[websockets]

# ports/cpprestsdk/portfile.cmake
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        brotli      CPPREST_EXCLUDE_BROTLI
        websockets  CPPREST_EXCLUDE_WEBSOCKETS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        # Expands to "-DCPPREST_EXCLUDE_BROTLI=ON;-DCPPREST_EXCLUDE_WEBSOCKETS=OFF"
        ${FEATURE_OPTIONS}
)
```

### Example 3: Set multiple options for same feature

```cmake
$ ./vcpkg install pcl[cuda]

# ports/pcl/portfile.cmake
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cuda  WITH_CUDA
        cuda  BUILD_CUDA
        cuda  BUILD_GPU
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        # Expands to "-DWITH_CUDA=ON;-DBUILD_CUDA=ON;-DBUILD_GPU=ON"
        ${FEATURE_OPTIONS}
)
```

### Example 4: Use regular and inverted features

```cmake
$ ./vcpkg install rocksdb[tbb]

# ports/rocksdb/portfile.cmake
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tbb   WITH_TBB
    INVERTED_FEATURES
        tbb   ROCKSDB_IGNORE_PACKAGE_TBB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        # Expands to "-DWITH_TBB=ON;-DROCKSDB_IGNORE_PACKAGE_TBB=OFF"
        ${FEATURE_OPTIONS}
)
```

## Examples in portfiles

* [cpprestsdk](https://github.com/microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
* [pcl](https://github.com/microsoft/vcpkg/blob/master/ports/pcl/portfile.cmake)
* [rocksdb](https://github.com/microsoft/vcpkg/blob/master/ports/rocksdb/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_check\_features.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_check_features.cmake)
