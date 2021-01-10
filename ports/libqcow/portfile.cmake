vcpkg_fail_port_install(ON_TARGET "uwp")
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(LIB_VERSION 20200928)
set(LIB_FILENAME libqcow-alpha-${LIB_VERSION}.tar.gz)

# Release distribution file contains configured sources, while the source code in the repository does not.
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libyal/libqcow/releases/download/${LIB_VERSION}/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 c0112bb26924b82ea84eb14a5d5b2ec53a421159de97a6136b3af0940453fba1ca46a7f8130429d5f812ccb3625e93aa3e4237278575fe439b918bc14b0565a5
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

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/libqcow" TARGET_PATH "share/libqcow")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# License and man
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
