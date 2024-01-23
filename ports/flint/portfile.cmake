
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flintlib/flint
    REF "v${VERSION}"
    SHA512 4b5b432b962135cd708a0ce4242343f3226f0fdf73c3f541728ed4540e7ef6cb7812a48b6b46e65a8fcc1f5cae93d8bb59838d24728024cd9aa0f7b8e5c6f98f
    HEAD_REF main
    PATCHES fix-cmakelists.patch
)

vcpkg_find_acquire_program(PYTHON3)

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
