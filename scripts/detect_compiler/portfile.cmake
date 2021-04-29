set(TOOLCHAIN_MESSAGES_FILE "${CURRENT_BUILDTREES_DIR}/config-${TARGET_TRIPLET}-messages.log")
set(LOGS
    "${TOOLCHAIN_MESSAGES_FILE}"
    "${CURRENT_BUILDTREES_DIR}/config-${TARGET_TRIPLET}-out.log"
    "${CURRENT_BUILDTREES_DIR}/config-${TARGET_TRIPLET}-rel-out.log"
    "${CURRENT_BUILDTREES_DIR}/config-${TARGET_TRIPLET}-dbg-out.log"
    "${CURRENT_BUILDTREES_DIR}/config-${TARGET_TRIPLET}-rel-err.log"
    "${CURRENT_BUILDTREES_DIR}/config-${TARGET_TRIPLET}-dbg-err.log"
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
        "-DZ_VCPKG_TOOLCHAIN_MESSAGES_FILE=${TOOLCHAIN_MESSAGES_FILE}"
)

foreach(LOG IN LISTS LOGS)
    if(EXISTS ${LOG})
        file(READ "${LOG}" _contents)
        message("${_contents}")
        if(LOG STREQUAL TOOLCHAIN_MESSAGES_FILE AND _contents MATCHES "Fatal error:")
            message(FATAL_ERROR "Compiler detection failed")
        endif()
    endif()
endforeach()
