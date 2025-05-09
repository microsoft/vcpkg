vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO github/cmark-gfm
    REF 0.29.0.gfm.13
    SHA512 435298fcf782dfc5b64c578ac839759b9d5cd0c08eb90d6702f26278062a0f4887c65c18e89e2c9f6be23f10dd835c769a7e0f8c934be068b6754dcca30cdd7c
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMARK_TESTS=OFF
        -DCMARK_STATIC=ON
        -DCMARK_SHARED=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
