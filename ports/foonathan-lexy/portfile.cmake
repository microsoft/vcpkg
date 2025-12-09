string(REGEX REPLACE "^([0-9]+)[.]([0-9][.])" "\\1.0\\2" LEXY_VERSION "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO foonathan/lexy
    REF "v${LEXY_VERSION}"
    SHA512 04eec38823ab7e6d67fe2017f9d09485ec0e2a2fa60182732e1b7a471944290934f10ded5ad209965efa0931a8f9db8bcf789ca8fb52a371b776d12edd8ca8f5
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLEXY_BUILD_BENCHMARKS=OFF
        -DLEXY_BUILD_EXAMPLES=OFF
        -DLEXY_BUILD_TESTS=OFF
        -DLEXY_BUILD_DOCS=OFF
        -DLEXY_BUILD_PACKAGE=OFF
        -DLEXY_ENABLE_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME lexy
    CONFIG_PATH lib/cmake/lexy
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
