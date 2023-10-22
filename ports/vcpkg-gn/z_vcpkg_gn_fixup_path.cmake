function(z_vcpkg_gn_fixup_path_internal)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "BUILD_DIR" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Internal error: install was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED arg_BUILD_DIR)
        message(FATAL_ERROR "BUILD_DIR must be specified.")
    endif()
 
    file(GLOB_RECURSE NINJA_FILES LIST_DIRECTORIES false "${arg_BUILD_DIR}/*.ninja")
 
    # replace all ../../../C$:/ pattern to C$:/ using regex: (\.\.\/)+([a-zA-Z]\$:\/)
    # (cmake regex is function limited, any plan for implementing a vcpkg built-in full functional regex?)
    set(NINJA_FIX_REGEX [=[(\.\.\/)+([a-zA-Z]\$:\/)]=]) 
    foreach(NINJA_FILE IN LISTS NINJA_FILES)
        file(READ "${NINJA_FILE}" NINJA_CONTENT)
        string(REGEX REPLACE "${NINJA_FIX_REGEX}" "\\2" NINJA_CONTENT_PATH_FIXED "${NINJA_CONTENT}")
        file(WRITE "${NINJA_FILE}" "${NINJA_CONTENT_PATH_FIXED}")
    endforeach()
endfunction()

function(z_vcpkg_gn_fixup_path)

    if (NOT VCPKG_HOST_IS_WINDOWS)
        return()
    endif()

    message(STATUS "vcpkg-gn: fixing ninja paths for Windows")

    cmake_parse_arguments(PARSE_ARGV 0 arg "" "" "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_fixup_gn_path was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        z_vcpkg_gn_fixup_path_internal(
                BUILD_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
        )
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        z_vcpkg_gn_fixup_path_internal(
                BUILD_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
        )
    endif()
endfunction()
