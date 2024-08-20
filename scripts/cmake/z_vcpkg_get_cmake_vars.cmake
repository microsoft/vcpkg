function(z_vcpkg_get_cmake_vars out_file)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "" "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(DEFINED VCPKG_BUILD_TYPE)
        set(cmake_vars_file "${CURRENT_BUILDTREES_DIR}/cmake-vars-${TARGET_TRIPLET}-${VCPKG_BUILD_TYPE}.cmake.log")
        set(cache_var "Z_VCPKG_GET_CMAKE_VARS_FILE_${VCPKG_BUILD_TYPE}")
    else()
        set(cmake_vars_file "${CURRENT_BUILDTREES_DIR}/cmake-vars-${TARGET_TRIPLET}.cmake.log")
        set(cache_var Z_VCPKG_GET_CMAKE_VARS_FILE)
    endif()
    if(NOT DEFINED CACHE{${cache_var}})
        set(${cache_var}  "${cmake_vars_file}"
            CACHE PATH "The file to include to access the CMake variables from a generated project.")
        vcpkg_configure_cmake(
            SOURCE_PATH "${SCRIPTS}/get_cmake_vars"
            OPTIONS_DEBUG "-DVCPKG_OUTPUT_FILE:PATH=${CURRENT_BUILDTREES_DIR}/cmake-vars-${TARGET_TRIPLET}-dbg.cmake.log"
            OPTIONS_RELEASE "-DVCPKG_OUTPUT_FILE:PATH=${CURRENT_BUILDTREES_DIR}/cmake-vars-${TARGET_TRIPLET}-rel.cmake.log"
            PREFER_NINJA
            LOGNAME get-cmake-vars-${TARGET_TRIPLET}
            Z_GET_CMAKE_VARS_USAGE # ignore vcpkg_cmake_configure, be quiet, don't set variables...
        )

        set(include_string "")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            string(APPEND include_string "include(\"\${CMAKE_CURRENT_LIST_DIR}/cmake-vars-${TARGET_TRIPLET}-rel.cmake.log\")\n")
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            string(APPEND include_string "include(\"\${CMAKE_CURRENT_LIST_DIR}/cmake-vars-${TARGET_TRIPLET}-dbg.cmake.log\")\n")
        endif()
        file(WRITE "${cmake_vars_file}" "${include_string}")
    endif()

    set("${out_file}" "${${cache_var}}" PARENT_SCOPE)
endfunction()
