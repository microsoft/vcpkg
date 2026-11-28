vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO VolaDynamics/vtz
    REF 61fde0db61ea17293e8c0cf06ea34d9212e1d637
    SHA512 c48eac7d0ab227b7744f06f985305aaa180bd92e9e2cf9cdf702b63a7d037749e10ff2f78a2b9c49615eb3919193da8b6a78bc8d277ceb57a035ee8f412c7bde
    HEAD_REF main
    PATCHES
        use-packaged-unordered-dense.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" VTZ_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVTZ_ONLY=ON
        -DVTZ_BUILD_SHARED=${VTZ_BUILD_SHARED}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/vtz)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # Bake the static linkage into the installed header. Upstream only defines
    # VTZ_STATIC_DEFINE through its CMake target, so consumers that include the
    # header directly would otherwise request __imp_ symbols on Windows.
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/vtz/impl/export.h"
        "#ifdef VTZ_STATIC_DEFINE"
        "#if 1 /* VTZ_STATIC_DEFINE */"
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
