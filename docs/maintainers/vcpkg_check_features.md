# vcpkg_check_feature(s)

Check if one or more features are part of the package installation. 

## Usage
```cmake
vcpkg_check_feature(
    <feature> <output_variable>
)

vcpkg_check_features(
    <feature1> <output_variable1>
    [<feature2> <output_variable2>]
    ...
)
```

`vcpkg_check_feature` accepts two arguments: a feature, and an output variable.

`vcpkg_check_feature` accepts a list of (feature, output_variable) pairs.
The syntax is similar to the `PROPERTIES` argument of `set_target_properties`.

`vcpkg_check_features` will create a variable `FEATURE_OPTIONS` in the
parent scope, which you can pass as a part of `OPTIONS` argument when
calling functions like `vcpkg_config_cmake`:
```cmake
vcpkg_config_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=0
        ${FEATURE_OPTIONS}
)
```

`vcpkg_check_features` is supposed to be called only once. Otherwise, the
`FEATURE_OPTIONS` variable set by a previous call will be overwritten.


## Source
[scripts/cmake/vcpkg_check_features.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_check_features.cmake)
