## # vcpkg_check_feature(s)
##
## Check if one or more features are part of the package installation. 
##
## ## Usage
## ```cmake
## vcpkg_check_feature(
##     <feature> <output_variable>
## )
##
## vcpkg_check_features(
##     <feature1> <output_variable1>
##     [<feature2> <output_variable2>]
##     ...
## )
## ```
##
## `vcpkg_check_feature` accepts two arguments: a feature, and an output variable.
##
## `vcpkg_check_feature` accepts a list of (feature, output_variable) pairs.
## The syntax is similar to the `PROPERTIES` argument of `set_target_properties`.
##
## `vcpkg_check_features` will create a variable `FEATURE_OPTIONS` in the
## parent scope, which you can pass as a part of `OPTIONS` argument when
## calling functions like `vcpkg_config_cmake`:
## ```cmake
## vcpkg_config_cmake(
##     SOURCE_PATH ${SOURCE_PATH}
##     PREFER_NINJA
##     OPTIONS
##         -DBUILD_TESTING=0
##         ${FEATURE_OPTIONS}
## )
## ```
##
## `vcpkg_check_features` is supposed to be called only once. Otherwise, the
## `FEATURE_OPTIONS` variable set by a previous call will be overwritten.
##
macro(vcpkg_check_feature feature output_variable)
    if(NOT ${feature} IN_LIST ALL_FEATURES)
        message(FATAL_ERROR "Unknown feature: ${feature}")
    endif()

    if(${feature} IN_LIST FEATURES)
        set(${output_variable} 1)
    else()
        set(${output_variable} 0)
    endif()
endmacro()


function(vcpkg_check_features)
    cmake_parse_arguments(_vcf "" "" "" ${ARGN})

    list(LENGTH ARGN _vcf_ARGC)
    math(EXPR _vcf_INCORRECT_ARGN "${_vcf_ARGC} % 2")

    if(_vcf_INCORRECT_ARGN)
        message(FATAL_ERROR "Called with incorrect number of arguments.")
    endif()

    set(_vcf_IS_FEATURE_ARG 1)
    set(_vcf_FEATURE_OPTIONS)

    # feature1 output_var1
    # feature2 output_var2
    # ...
    foreach(_vcf_ARG ${ARGN})
        if(_vcf_IS_FEATURE_ARG)
            set(_vcf_FEATURE ${_vcf_ARG})
            set(_vcf_IS_FEATURE_ARG 0)
        else()
            set(_vcf_FEATURE_VAR ${_vcf_ARG})
            vcpkg_check_feature(${_vcf_FEATURE} ${_vcf_FEATURE_VAR})
            set(${_vcf_FEATURE_VAR} ${${_vcf_FEATURE_VAR}} PARENT_SCOPE)
            list(APPEND _vcf_FEATURE_OPTIONS "-D${_vcf_FEATURE_VAR}=${${_vcf_FEATURE_VAR}}")
            set(_vcf_IS_FEATURE_ARG 1)
        endif()
    endforeach()

    if(DEFINED FEATURE_OPTIONS)
        message(WARNING "FEATURE_OPTIONS is already defined and will be overwritten.")
    endif()

    set(FEATURE_OPTIONS ${_vcf_FEATURE_OPTIONS} PARENT_SCOPE)
endfunction()
