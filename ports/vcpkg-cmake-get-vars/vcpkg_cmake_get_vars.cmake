include_guard(GLOBAL)

set(Z_VCPKG_CMAKE_GET_VARS_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "")

function(vcpkg_cmake_get_vars out_file)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "" "ADDITIONAL_LANGUAGES")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    set(languages C CXX ${arg_ADDITIONAL_LANGUAGES})
    list(SORT languages)
    list(REMOVE_DUPLICATES languages)

    string(MAKE_C_IDENTIFIER "_${languages}" configuration_suffix)
    if(NOT DEFINED CACHE{Z_VCPKG_CMAKE_GET_VARS_FILE${configuration_suffix}})
        set("Z_VCPKG_CMAKE_GET_VARS_FILE${configuration_suffix}" "${CURRENT_BUILDTREES_DIR}/cmake-get-vars${configuration_suffix}-${TARGET_TRIPLET}.cmake.log"
            CACHE PATH "The file to include to access the CMake variables from a generated project.")
        vcpkg_cmake_configure(
            SOURCE_PATH "${Z_VCPKG_CMAKE_GET_VARS_CURRENT_LIST_DIR}/cmake_get_vars"
            OPTIONS "-DVCPKG_LANGUAGES=${languages}"
            OPTIONS_DEBUG "-DVCPKG_OUTPUT_FILE:PATH=${CURRENT_BUILDTREES_DIR}/cmake-get-vars${configuration_suffix}-${TARGET_TRIPLET}-dbg.cmake.log"
            OPTIONS_RELEASE "-DVCPKG_OUTPUT_FILE:PATH=${CURRENT_BUILDTREES_DIR}/cmake-get-vars${configuration_suffix}-${TARGET_TRIPLET}-rel.cmake.log"
            LOGFILE_BASE cmake-get-vars${configuration_suffix}-${TARGET_TRIPLET}
            Z_CMAKE_GET_VARS_USAGE # be quiet, don't set variables...
        )
        configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/cmake-get-vars.cmake.in" "${Z_VCPKG_CMAKE_GET_VARS_FILE${configuration_suffix}}" @ONLY)
    endif()

    set("${out_file}" "${Z_VCPKG_CMAKE_GET_VARS_FILE${configuration_suffix}}" PARENT_SCOPE)
endfunction()
