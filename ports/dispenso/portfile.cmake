vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookincubator/dispenso
    REF "v${VERSION}"
    SHA512 2d8c954c150488b9765bb36e6907137df93f37ad4fcc70d14e736c483e169448d3739f05a2faa19f5cc1f9a03bedb9c308933e01c8d81d46d372254a84a27820
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDISPENSO_BUILD_TESTS=OFF
        -DDISPENSO_BUILD_BENCHMARKS=OFF
        -DDISPENSO_USE_SYSTEM_CONCURRENTQUEUE=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Dispenso-${VERSION}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
