vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/re2
    REF 0f6c07eae69151e606acb3d9232750c3442dff23
    SHA512 bb75832ecb1d5e727331d9735b556da0778519947dc71a9540aed1b5a9bd01e0de0b35c10ea2a1e80f2fdeff73508f6cb9bc7c6c10f01b7f951121aa3a8b8e4f
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
