include(vcpkg_common_functions)

set(PIXMAN_VERSION 0.38.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.cairographics.org/releases/pixman-${PIXMAN_VERSION}.tar.gz"
    FILENAME "pixman-${PIXMAN_VERSION}.tar.gz"
    SHA512 1b0205dbe9d9185c68813ce577a889f3c83e83fbd9955c3a72d411c3b476e6be93fc246b5b6ef4ee17e2bb8eb6fb5559e01dff7feb6a6c4c6314f980e960d690
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${PIXMAN_VERSION}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/pixman)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/pixman
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-pixman TARGET_PATH share/unofficial-pixman)

# Copy the appropriate header files.
file(COPY
    "${SOURCE_PATH}/pixman/pixman.h"
    "${SOURCE_PATH}/pixman/pixman-accessor.h"
    "${SOURCE_PATH}/pixman/pixman-combine32.h"
    "${SOURCE_PATH}/pixman/pixman-compiler.h"
    "${SOURCE_PATH}/pixman/pixman-edge-imp.h"
    "${SOURCE_PATH}/pixman/pixman-inlines.h"
    "${SOURCE_PATH}/pixman/pixman-private.h"
    "${SOURCE_PATH}/pixman/pixman-version.h"
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/pixman)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pixman/COPYING ${CURRENT_PACKAGES_DIR}/share/pixman/copyright)

vcpkg_copy_pdbs()

vcpkg_test_cmake(PACKAGE_NAME unofficial-pixman)
