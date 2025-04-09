
vcpkg_download_distfile(ARCHIVE
    URLS "https://flintlib.org/download/flint-${VERSION}.zip"
    FILENAME "flint-${VERSION}.zip"
    SHA512 3dd9a4e79e08ab6bc434a786c8d4398eba6cb04e57bcb8d01677f4912cddf20ed3a971160a3e2d533d9a07b728678b0733cc8315bcb39a3f13475b6efa240062
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
