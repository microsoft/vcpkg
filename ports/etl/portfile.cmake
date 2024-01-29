vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ETLCPP/etl
    REF "${VERSION}"
    SHA512 fcfa30f4e702444b7cc9a41c97ba8c370e18468782a11fcde40d198f7f0475b3f6e45531c8fe2898e5ab0086c24f0cf9dc72ebf8c16480ac3c09dd301c476f0a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
