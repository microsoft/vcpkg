vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/re2
    REF 927f5d53caf8111721e734cf24724686bb745f55
    SHA512 35103a46a6350084f2d09ccfcf4322dac7364c61fbdad8bfcbd41b39990f83a260d2a8cd5ca019a3f24b71faf1588c7dabf07c3dddae5268bcc5b9502b87658a
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
