vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ai-university-aiu/causalontology
    REF "v${VERSION}"
    SHA512 1e8cf24caa7b77a96c6a94a497171115035bbd90ad112180ee5d4ddcd9acaceca525da251b9e851e8e3b2915a26969e8a6049160c0a840143cea7057a37385a2
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/bindings/cpp"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME causalontology CONFIG_PATH lib/cmake/causalontology)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
