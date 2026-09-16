# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mas-bandwidth/serialize
    REF "v${VERSION}"
    SHA512 10ee9e79eb7bd0bbb9c7f43e5ba1a0e392143f05ee716518014d8df2bd08d59babf98f6ddb381efcee8d300f097f7ac53ddddc0975502e4efb143fc5362482b1
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSERIALIZE_BUILD_TESTS=OFF
        -DSERIALIZE_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME serialize CONFIG_PATH lib/cmake/serialize)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
