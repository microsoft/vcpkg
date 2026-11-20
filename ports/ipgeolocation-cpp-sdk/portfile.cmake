vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IPGeolocation/ip-geolocation-api-cpp-sdk
    REF "v${VERSION}"
    SHA512 5eb7f4bf07a83845db00ac6e228060c619550f143062d82fff03206c2362d60b2f598267c814123df9024740752ae598d5a6e951d7596744166bd79f2ba602ea
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DIPGEOLOCATION_BUILD_TESTS=OFF
        -DIPGEOLOCATION_ENABLE_COVERAGE=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/ipgeolocation")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
