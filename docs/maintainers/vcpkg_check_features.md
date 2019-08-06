# vcpkg_check_features
Check if one or more features are a part of a package installation.

## Usage
```cmake
vcpkg_check_features(
  OUT_FEATURE_OPTIONS <output_variable>  
  [FEATURES
    <feature1> <output_variable1>
    [<feature2> <output_variable2>]
    ...]
  [INVERTED_FEATURES
    <feature3> <output_variable3>
    [<feature4> <output_variable4>]
    ...]
)
```
`vcpkg_check_features()` accepts these parameters: 

* `OUT_FEATURE_OPTIONS`:  
  An output variable to contain a list of definitions for each feature.  
  This is a required parameter.
  
* `FEATURES`:  
  A list of (`FEATURE_NAME`, `OPTION_NAME`) pairs.  
  For each `FEATURE_NAME` a definition is added to `OUT_FEATURE_OPTIONS` in the form of:   
    
    * `-D<OPTION_NAME>=ON`, if a feature is specified for installation,
    * `-D<OPTION_NAME>=OFF`, otherwise. 

* `INVERTED_FEATURES`:  
  A list of (`FEATURE_NAME`, `OPTION_NAME`) pairs, uses reversed logic from `FEATURES`.  
  For each `FEATURE_NAME` a definition is added to `OUT_FEATURE_OPTIONS` in the form of:   
    
    * `-D<OPTION_NAME>=OFF`, if a feature is specified for installation,
    * `-D<OPTION_NAME>=ON`, otherwise. 

## Notes

The `FEATURES` name parameter can be omitted if no `INVERTED_FEATURES` are used.

At least one (`FEATURE_NAME`, `OPTION_NAME`) pair must be passed to the function call.

Arguments passed to `FEATURES` and `INVERTED_FEATURES` are not validated to prevent duplication.  
If the same (`FEATURE_NAME`, `OPTION_NAME`) pair is passed to both lists, 
two conflicting definitions are added to `OUT_FEATURE_OPTIONS`.


## Examples

### Example 1: Regular features

```cmake
$ ./vcpkg install mimalloc[asm,secure]

# ports/mimalloc/portfile.cmake
vcpkg_check_features(OUT_FEATURE_OPTIONS mimalloc_FEATURE_OPTIONS
  # Keyword FEATURES is optional if INVERTED_FEATURES are not used
    asm       MI_SEE_ASM
    override  MI_OVERRIDE
    secure    MI_SECURE
)

vcpkg_config_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    # Expands to "-DMI_SEE_ASM=ON; -DMI_OVERRIDE=OFF; -DMI_SECURE=ON"
    ${mimalloc_FEATURE_OPTIONS}
)
```

### Example 2: Inverted features

```cmake
$ ./vcpkg install cpprestsdk[websockets]

# ports/cpprestsdk/portfile.cmake
vcpkg_check_features(OUT_FEATURE_OPTIONS cpprestsdk_FEATURE_OPTIONS
  INVERTED_FEATURES # <- Keyword INVERTED_FEATURES required
    brotli      CPPREST_EXCLUDE_BROTLI
    websockets  CPPREST_EXCLUDE_WEBSOCKETS
)

vcpkg_config_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    # Expands to "-DCPPREST_EXCLUDE_BROTLI=ON; -DCPPREST_EXCLUDE_WEBSOCKETS=OFF"
    ${cpprestsdk_FEATURE_OPTIONS}
)
```

### Example 3: Mixed regular and inverted features

```cmake
$ ./vcpkg install rocksdb[tbb]

# ports/rocksdb/portfile.cmake
vcpkg_check_features(OUT_FEATURE_OPTIONS rocksdb_FEATURE_OPTIONS
  FEATURES # <- Keyword FEATURES is required because INVERTED_FEATURES are being used
    tbb   WITH_TBB
  INVERTED_FEATURES
    tbb   ROCKSDB_IGNORE_PACKAGE_TBB
)

vcpkg_config_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    # Expands to "-DWITH_TBB=ON; -DROCKSDB_IGNORE_PACKAGE_TBB=OFF"
    ${rocksdb_FEATURE_OPTIONS}
)
``` 

## Examples in portfiles

* [czmq](https://github.com/microsoft/vcpkg/blob/master/ports/czmq/portfile.cmake)
* [xsimd](https://github.com/microsoft/vcpkg/blob/master/ports/xsimd/portfile.cmake)
* [xtensor](https://github.com/microsoft/vcpkg/blob/master/ports/xtensor/portfile.cmake)


## Source
[scripts/cmake/vcpkg_check_features.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_check_features.cmake)
