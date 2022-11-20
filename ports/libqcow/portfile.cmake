vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(LIB_VERSION 20210419)
set(LIB_FILENAME libqcow-alpha-${LIB_VERSION}.tar.gz)

# Release distribution file contains configured sources, while the source code in the repository does not.
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libyal/libqcow/releases/download/${LIB_VERSION}/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 911d29bd880df95288e552356d128d18c924fcd0d61d166fbeaf09936f11bf27b984d8ffd4cdc4bc285e7df295a1fe64ff595b0dfdd10b6fcfbdc6586d6bd3b0
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${LIB_VERSION}
    PATCHES macos_fixes.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
)
vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/libqcow")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# License and man
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
