vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/mvfst
    REF "v${VERSION}"
    SHA512 edfcfcf47d9cf18c91bad9a81fb4193e1cb03645349b9c42943b8c8dabd774a406b5fc9cfe76bd270661c4f58d9c4fcdc29816176335564b0f21ca95c6a82b4c
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mvfst)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
