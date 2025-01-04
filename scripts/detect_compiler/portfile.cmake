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
    OPTIONS
        "-DVCPKG_COMPILER_CACHE_FILE=${VCPKG_COMPILER_CACHE_FILE}"

)

foreach(LOG IN LISTS LOGS)
    if(EXISTS ${LOG})
        file(READ "${LOG}" _contents)
        message("${_contents}")
    endif()
endforeach()
