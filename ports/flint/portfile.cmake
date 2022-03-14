set(FLINT_VERSION 2.8.0)
set(FLINT_HASH "916285d13a55d12a041236195a9d7bbc5c1c3c30c3aa2f169efee6063b800d34f96ad3235f1c77285b04305ce685e5890169c984108d50d0c9ee7a77c3f6e73d")

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.flintlib.org/flint-${FLINT_VERSION}.zip"
    FILENAME "flint-${FLINT_VERSION}.zip"
    SHA512 ${FLINT_HASH}
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
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
