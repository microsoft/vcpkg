# vcpkg_check_features
Check if one or more features are a part of the package installation.

## Usage
```cmake
vcpkg_check_features(
  [OUT_EXPAND_OPTIONS <output_variable>] 
  CHECK_FEATURES
    <feature1> <output_variable1>
    [<feature2> <output_variable2>]
    ...
)
```
`vcpkg_check_features()` accepts two parameters: 

* `OUT_EXPAND_OPTIONS`:  
  An output variable that will be set to contain the definitions (`-D<FEATURE_VAR>=ON|OFF`) for each checked ## feature.
  
* `CHECK_FEATURES`:  
  A list of (feature, output variable) pairs. If a feature is specified for installation, the corresponding output 
  variable will be set as `ON`, or `OFF` otherwise.  
  
  The syntax is similar to the `PROPERTIES` argument of `set_target_properties`.

The output variable set in `OUT_EXPAND_OPTIONS` can be passed as a part of the `OPTIONS` argument when calling ## functions like `vcpkg_config_cmake`:
```cmake
vcpkg_check_features(OUT_EXPAND_OPTIONS PORT_FEATURE_OPTIONS)
vcpkg_config_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${PORT_FEATURE_OPTIONS}
)
```
## Notes

```cmake
vcpkg_check_features(CHECK_FEATURES <feature> <output_variable>)
```

can be used as a replacement of:

```cmake
if(<feature> IN_LIST FEATURES)
    set(<output_variable> ON)
else()
    set(<output_variable> OFF)
endif()
```

However, if you have a feature that was checked like this before:

```cmake
if(<feature> IN_LIST FEATURES)
    set(<output_variable> OFF)
else()
    set(<output_variable> ON)
endif()
```

then you should not use `vcpkg_check_features` instead. [```oniguruma```](https://github.com/microsoft/vcpkg/blob/## master/ports/oniguruma/portfile.cmake), for example, has a feature named `non-posix` which is checked with:
```cmake
if("non-posix" IN_LIST FEATURES)
    set(ENABLE_POSIX_API OFF)
else()
    set(ENABLE_POSIX_API ON)
endif()
```
and by replacing these code with:
```cmake
vcpkg_check_features(non-posix ENABLE_POSIX_API)
```
is totally wrong.

## Examples
* [czmq](https://github.com/microsoft/vcpkg/blob/master/ports/czmq/portfile.cmake)
* [xsimd](https://github.com/microsoft/vcpkg/blob/master/ports/xsimd/portfile.cmake)
* [xtensor](https://github.com/microsoft/vcpkg/blob/master/ports/xtensor/portfile.cmake)
 

## Source
[scripts/cmake/vcpkg_check_features.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_check_features.cmake)
