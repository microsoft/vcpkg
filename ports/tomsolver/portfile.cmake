vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tomwillow/tomsolver
    REF "${VERSION}"
    SHA512 332301dc8df2756818e709655f726193dd424fb04fba2e18b4264fa078120a6da9cc6a164c930a440439b1b34f7f6a8afc9263db5e8c16e6cd99391296ab0296
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
