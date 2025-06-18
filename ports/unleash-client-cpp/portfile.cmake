vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aruizs/unleash-client-cpp
    REF "v${VERSION}"
    SHA512 0ba3fa89bacfded6aaf54c5595ec4affc621563dc0b2b7917f5a444cb322336fa8c85ce236ef7ba3726edce778d00c6ad827b3a5bd3c4022898ae0eba872d869
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_REQUIRE_FIND_PACKAGE_cpr=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_nlohmann_json=ON
        -DENABLE_TESTING=OFF
        -DENABLE_TEST_COVERAGE=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/unleash" PACKAGE_NAME "unleash")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
