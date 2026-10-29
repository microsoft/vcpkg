vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aruizs/unleash-client-cpp
    REF "v${VERSION}"
    SHA512 61c1cce7c4ad1b994b0c233978ef45b109a503d2812b9cd68e9b9b97277a37bdbeedc080c706b90a76945f3039fc13316b51f213d1de093fdb2f9dee8e6ccdd1
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_REQUIRE_FIND_PACKAGE_cpr=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_nlohmann_json=ON
        -DUNLEASH_ENABLE_TESTING=OFF
        -DUNLEASH_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/unleash" PACKAGE_NAME "unleash")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
