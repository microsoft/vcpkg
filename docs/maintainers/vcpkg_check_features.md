# vcpkg_check_features

Check if one or more features are a part of the package installation.

## Usage
```cmake
vcpkg_check_features(
    <feature1> <output_variable1>
    [<feature2> <output_variable2>]
    ...
)
```

`vcpkg_check_features` accepts a list of (feature, output_variable) pairs. If a feature is specified, the corresponding output variable will be set as `ON`, or `OFF` otherwise. The syntax is similar to the `PROPERTIES` argument of `set_target_properties`.

`vcpkg_check_features` will create a variable `FEATURE_OPTIONS` in the parent scope, which you can pass as a part of `OPTIONS` argument when calling functions like `vcpkg_config_cmake`:
```cmake
vcpkg_config_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=ON
        ${FEATURE_OPTIONS}
)
```

## Notes
```cmake
vcpkg_check_features(<feature> <output_variable>)
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
then you should not use `vcpkg_check_features` instead. [```oniguruma```](https://github.com/microsoft/vcpkg/blob/master/ports/oniguruma/portfile.cmake), for example, has a feature named `non-posix` which is checked with:
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

`vcpkg_check_features` is supposed to be called only once. Otherwise, the `FEATURE_OPTIONS` variable set by a previous call will be overwritten.

## Examples

* [czmq](https://github.com/microsoft/vcpkg/blob/master/ports/czmq/portfile.cmake)
* [xsimd](https://github.com/microsoft/vcpkg/blob/master/ports/xsimd/portfile.cmake)
* [xtensor](https://github.com/microsoft/vcpkg/blob/master/ports/xtensor/portfile.cmake)

## Source
[scripts/cmake/vcpkg_check_features.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_check_features.cmake)
