## # vcpkg_check_features
##
## Check if one or more features are a part of the package installation.
##
## ## Usage
## ```cmake
## vcpkg_check_features(
##     <feature1> <output_variable1>
##     [<feature2> <output_variable2>]
##     ...
## )
## ```
##
## `vcpkg_check_features` accepts a list of (feature, output_variable) pairs. If a feature is specified, the corresponding output variable will be set as `ON`, or `OFF` otherwise. The syntax is similar to the `PROPERTIES` argument of `set_target_properties`.
##
## `vcpkg_check_features` will create a variable `FEATURE_OPTIONS` in the parent scope, which you can pass as a part of `OPTIONS` argument when calling functions like `vcpkg_config_cmake`:
## ```cmake
## vcpkg_config_cmake(
##     SOURCE_PATH ${SOURCE_PATH}
##     PREFER_NINJA
##     OPTIONS
##         -DBUILD_TESTING=ON
##         ${FEATURE_OPTIONS}
## )
## ```
##
## ## Notes
## ```cmake
## vcpkg_check_features(<feature> <output_variable>)
## ```
## can be used as a replacement of:
## ```cmake
## if(<feature> IN_LIST FEATURES)
##     set(<output_variable> ON)
## else()
##     set(<output_variable> OFF)
## endif()
## ```
##
## However, if you have a feature that was checked like this before:
## ```cmake
## if(<feature> IN_LIST FEATURES)
##     set(<output_variable> OFF)
## else()
##     set(<output_variable> ON)
## endif()
## ```
## then you should not use `vcpkg_check_features` instead. [```oniguruma```](https://github.com/microsoft/vcpkg/blob/master/ports/oniguruma/portfile.cmake), for example, has a feature named `non-posix` which is checked with:
## ```cmake
## if("non-posix" IN_LIST FEATURES)
##     set(ENABLE_POSIX_API OFF)
## else()
##     set(ENABLE_POSIX_API ON)
## endif()
## ```
## and by replacing these code with:
## ```cmake
## vcpkg_check_features(non-posix ENABLE_POSIX_API)
## ```
## is totally wrong.
##
## `vcpkg_check_features` is supposed to be called only once. Otherwise, the `FEATURE_OPTIONS` variable set by a previous call will be overwritten.
##
## ## Examples
##
## * [czmq](https://github.com/microsoft/vcpkg/blob/master/ports/czmq/portfile.cmake)
## * [xsimd](https://github.com/microsoft/vcpkg/blob/master/ports/xsimd/portfile.cmake)
## * [xtensor](https://github.com/microsoft/vcpkg/blob/master/ports/xtensor/portfile.cmake)
function(vcpkg_check_features)
    cmake_parse_arguments(_vcf "" "" "" ${ARGN})

    list(LENGTH ARGN _vcf_ARGC)
    math(EXPR _vcf_INCORRECT_ARGN "${_vcf_ARGC} % 2")

    if(_vcf_INCORRECT_ARGN)
        message(FATAL_ERROR "Called with incorrect number of arguments.")
    endif()

    set(_vcf_IS_FEATURE_ARG ON)
    set(_vcf_FEATURE_OPTIONS)

    # Process (feature, output_var) pairs
    foreach(_vcf_ARG ${ARGN})
        if(_vcf_IS_FEATURE_ARG)
            set(_vcf_FEATURE ${_vcf_ARG})

            if(NOT ${_vcf_FEATURE} IN_LIST ALL_FEATURES)
                message(FATAL_ERROR "Unknown feature: ${_vcf_FEATURE}")
            endif()

            set(_vcf_IS_FEATURE_ARG OFF)
        else()
            set(_vcf_FEATURE_VAR ${_vcf_ARG})

            if(${_vcf_FEATURE} IN_LIST FEATURES)
                set(${_vcf_FEATURE_VAR} ON PARENT_SCOPE)
                list(APPEND _vcf_FEATURE_OPTIONS "-D${_vcf_FEATURE_VAR}=ON")
            else()
                set(${_vcf_FEATURE_VAR} OFF PARENT_SCOPE)
                list(APPEND _vcf_FEATURE_OPTIONS "-D${_vcf_FEATURE_VAR}=OFF")
            endif()

            set(_vcf_IS_FEATURE_ARG ON)
        endif()
    endforeach()

    if(DEFINED FEATURE_OPTIONS)
        message(WARNING "FEATURE_OPTIONS is already defined and will be overwritten.")
    endif()

    set(FEATURE_OPTIONS ${_vcf_FEATURE_OPTIONS} PARENT_SCOPE)
endfunction()
