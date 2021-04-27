if(VCPKG_NO_COMPILER_TRACKING)
    string(SHA1 hash "nocompilertracking")
    message("#COMPILER_HASH#${hash}")
    message("#COMPILER_C_HASH#${hash}")
    message("#COMPILER_C_VERSION#nocompilertracking")
    message("#COMPILER_C_ID#nocompilertracking")
    message("#COMPILER_CXX_HASH#${hash}")
    message("#COMPILER_CXX_VERSION#nocompilertracking")
    message("#COMPILER_CXX_ID#nocompilertracking")
    return()
endif()

set(LOGS
    ${CURRENT_BUILDTREES_DIR}/config-${TARGET_TRIPLET}-out.log
    ${CURRENT_BUILDTREES_DIR}/config-${TARGET_TRIPLET}-rel-out.log
    ${CURRENT_BUILDTREES_DIR}/config-${TARGET_TRIPLET}-dbg-out.log
    ${CURRENT_BUILDTREES_DIR}/config-${TARGET_TRIPLET}-rel-err.log
    ${CURRENT_BUILDTREES_DIR}/config-${TARGET_TRIPLET}-dbg-err.log
)

foreach(LOG IN LISTS LOGS)
    file(REMOVE ${LOG})
    if(EXISTS ${LOG})
        message(FATAL_ERROR "Could not remove ${LOG}")
    endif()
endforeach()

set(VCPKG_BUILD_TYPE release)

vcpkg_configure_cmake(
    SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}"
    PREFER_NINJA
)

foreach(LOG IN LISTS LOGS)
    if(EXISTS ${LOG})
        file(READ "${LOG}" _contents)
        message("${_contents}")
    endif()
endforeach()
