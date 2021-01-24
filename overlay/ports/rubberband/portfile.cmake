vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/be-ing/rubberband.git
    REF 3abe9d2ce8ada8b1d087cfc9d6f2f5199c727e14
)

# Find cross-compiler prefix
if(VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
endif()
if(CMAKE_C_COMPILER)
    vcpkg_execute_required_process(
        COMMAND ${CMAKE_C_COMPILER} -dumpmachine
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
        LOGNAME dumpmachine-${TARGET_TRIPLET}
    )
    file(READ ${CURRENT_BUILDTREES_DIR}/dumpmachine-${TARGET_TRIPLET}-out.log RUBBERBAND_HOST)
    string(REPLACE "\n" "" RUBBERBAND_HOST "${RUBBERBAND_HOST}")
    message(STATUS "Cross-compiling with ${CMAKE_C_COMPILER}")
    message(STATUS "Detected autoconf triplet --host=${RUBBERBAND_HOST}")
    message(STATUS "Options ${RUBBERBAND_OPTIONS}")
    set(RUBBERBAND_OPTIONS
        --host=${RUBBERBAND_HOST}
        ${RUBBERBAND_OPTIONS}
    )
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${RUBBERBAND_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/rubberband)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/rubberband RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
