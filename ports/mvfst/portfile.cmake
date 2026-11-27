vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO meta/mvfst
    REF "v${VERSION}"
    SHA512 feedf6717347361308e31f3c488c79b55ac5bb991ba319525d8d844ad80f071a1b318f7531c26688cf701d6e6708da71550ee8f9d7014647648ff251b64eddda
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
