vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  google/cppdap
    REF "dap-${VERSION}"
    SHA512 36f31cf7b90190820f5a5b7df679a3ca1a4f51b58a7a4c46f85c7b55b0ad9dbeba3436992b5eb8a3fd4499fc38bbf2b16f834f5f1989717f151abf13c262c747
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCPPDAP_USE_EXTERNAL_NLOHMANN_JSON_PACKAGE=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/cppdap")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
