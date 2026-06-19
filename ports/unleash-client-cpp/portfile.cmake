vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aruizs/unleash-client-cpp
    REF "v${VERSION}"
    SHA512 d3abe4eeca7020e14a7a8a9463b0f38c446e4f9c0174ae7d078af8d4402585a23d9ff37bfb80b59e81a35060f5a741adce8383e9a116cb34d4733e8ffc2fb662
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
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
