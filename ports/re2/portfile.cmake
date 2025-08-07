vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/re2
    REF 85c7c0fb1163b0bd83a7951f5a205ee7b489e33e
    SHA512 1933d5e5f0a90e00d1cf2d3ca9ec4a17808691f25eeb0e6da001ce19ecd52c6a5c76892706ed14f814d802aebb676d35999fb1b8e42614e310be45312ec56987
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRE2_TEST=OFF
        -DRE2_BENCHMARK=OFF
        -DRE2_BUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
