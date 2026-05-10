vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pantoniou/libfyaml
    REF "v${VERSION}"
    SHA512 04d8ef638a9995a2b0e2d561fd615aca24c4091f7369a1d2d3cb38f048ee13eccafeac90d92d758022e8fb2db273c97939fec3b9872cdb9a6ef6b42b511adf85
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libfyaml")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
