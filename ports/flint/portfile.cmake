
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.flintlib.org/flint-${VERSION}.zip"
    FILENAME "flint-${VERSION}.zip"
    SHA512 0
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix-cmakelists.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPYTHON_EXECUTABLE=${PYTHON3}
        -DWITH_NTL=OFF
        -DWITH_CBLAS=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/flint/flint-config.h"
        "#elif defined(MSC_USE_DLL)" "#elif 1"
    )
endif()

file(INSTALL "${SOURCE_PATH}/gpl-2.0.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
