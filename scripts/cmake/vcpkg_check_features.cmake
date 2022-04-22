#[===[.md:
# vcpkg_check_features
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
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        # Expands to "-DMI_SEE_ASM=ON;-DMI_OVERRIDE=OFF;-DMI_SECURE=ON"
        ${FEATURE_OPTIONS}
)
```

### Example 2: Inverted features

```cmake
$ ./vcpkg install cpprestsdk[websockets]

# ports/cpprestsdk/portfile.cmake
vcpkg_check_features(
    INVERTED_FEATURES
        brotli      CPPREST_EXCLUDE_BROTLI
        websockets  CPPREST_EXCLUDE_WEBSOCKETS
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        # Expands to "-DCPPREST_EXCLUDE_BROTLI=ON;-DCPPREST_EXCLUDE_WEBSOCKETS=OFF"
        ${FEATURE_OPTIONS}
)
```

### Example 3: Set multiple options for same feature

```cmake
$ ./vcpkg install pcl[cuda]

# ports/pcl/portfile.cmake
vcpkg_check_features(
    FEATURES
        cuda  WITH_CUDA
        cuda  BUILD_CUDA
        cuda  BUILD_GPU
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        # Expands to "-DWITH_CUDA=ON;-DBUILD_CUDA=ON;-DBUILD_GPU=ON"
        ${FEATURE_OPTIONS}
)
```

### Example 4: Use regular and inverted features

```cmake
$ ./vcpkg install rocksdb[tbb]

# ports/rocksdb/portfile.cmake
vcpkg_check_features(
    FEATURES
        tbb   WITH_TBB
    INVERTED_FEATURES
        tbb   ROCKSDB_IGNORE_PACKAGE_TBB
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        # Expands to "-DWITH_TBB=ON;-DROCKSDB_IGNORE_PACKAGE_TBB=OFF"
        ${FEATURE_OPTIONS}
)
```

## Examples in portfiles

* [cpprestsdk](https://github.com/microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
* [pcl](https://github.com/microsoft/vcpkg/blob/master/ports/pcl/portfile.cmake)
* [rocksdb](https://github.com/microsoft/vcpkg/blob/master/ports/rocksdb/portfile.cmake)
#]===]

function(z_vcpkg_check_features_last_feature out_var features_name features_list)
    list(LENGTH features_list features_length)
    math(EXPR features_length_mod_2 "${features_length} % 2")
    if(NOT features_length_mod_2 EQUAL 0)
        message(FATAL_ERROR "vcpkg_check_features has an incorrect number of arguments to ${features_name}")
    endif()

    math(EXPR last_feature "${features_length} / 2 - 1")
    set("${out_var}" "${last_feature}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_check_features_get_feature idx features_list out_feature_name out_feature_var)
    math(EXPR feature_name_idx "${idx} * 2")
    math(EXPR feature_var_idx "${feature_name_idx} + 1")

    list(GET features_list "${feature_name_idx}" feature_name)
    list(GET features_list "${feature_var_idx}" feature_var)

    set("${out_feature_name}" "${feature_name}" PARENT_SCOPE)
    set("${out_feature_var}" "${feature_var}" PARENT_SCOPE)
endfunction()

function(vcpkg_check_features)
    cmake_parse_arguments(
        PARSE_ARGV 0 "arg"
        ""
        "OUT_FEATURE_OPTIONS;PREFIX"
        "FEATURES;INVERTED_FEATURES"
    )

    if(NOT DEFINED arg_OUT_FEATURE_OPTIONS)
        message(FATAL_ERROR "OUT_FEATURE_OPTIONS must be defined.")
    endif()
    if(NOT DEFINED arg_PREFIX)
        set(prefix "")
    else()
        set(prefix "${arg_PREFIX}_")
    endif()

    set(feature_options)
    set(feature_variables)

    if(NOT DEFINED arg_FEATURES AND NOT DEFINED arg_INVERTED_FEATURES)
        message(DEPRECATION
"calling `vcpkg_check_features` without the `FEATURES` keyword has been deprecated.
    Please add the `FEATURES` keyword to the call.")
        set(arg_FEATURES "${arg_UNPARSED_ARGUMENTS}")
    elseif(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_check_features called with unknown arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()



    z_vcpkg_check_features_last_feature(last_feature "FEATURES" "${arg_FEATURES}")
    if(last_feature GREATER_EQUAL 0)
        foreach(feature_pair_idx RANGE "${last_feature}")
            z_vcpkg_check_features_get_feature("${feature_pair_idx}" "${arg_FEATURES}" feature_name feature_var)

            list(APPEND feature_variables "${feature_var}")
            if(feature_name IN_LIST FEATURES)
                list(APPEND feature_options "-D${feature_var}=ON")
                set("${prefix}${feature_var}" ON PARENT_SCOPE)
            else()
                list(APPEND feature_options "-D${feature_var}=OFF")
                set("${prefix}${feature_var}" OFF PARENT_SCOPE)
            endif()
        endforeach()
    endif()

    z_vcpkg_check_features_last_feature(last_inverted_feature "INVERTED_FEATURES" "${arg_INVERTED_FEATURES}")
    if(last_inverted_feature GREATER_EQUAL 0)
        foreach(feature_pair_idx RANGE "${last_inverted_feature}")
            z_vcpkg_check_features_get_feature("${feature_pair_idx}" "${arg_INVERTED_FEATURES}" feature_name feature_var)

            list(APPEND feature_variables "${feature_var}")
            if(feature_name IN_LIST FEATURES)
                list(APPEND feature_options "-D${feature_var}=OFF")
                set("${prefix}${feature_var}" OFF PARENT_SCOPE)
            else()
                list(APPEND feature_options "-D${feature_var}=ON")
                set("${prefix}${feature_var}" ON PARENT_SCOPE)
            endif()
        endforeach()
    endif()

    list(SORT feature_variables)
    set(last_variable)
    foreach(variable IN LISTS feature_variables)
        if(variable STREQUAL last_variable)
            message(FATAL_ERROR "vcpkg_check_features passed the same feature variable multiple times: '${variable}'")
        endif()
    endforeach()

    set("${arg_OUT_FEATURE_OPTIONS}" "${feature_options}" PARENT_SCOPE)
endfunction()
