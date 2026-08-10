# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mas-bandwidth/serialize
    REF "v${VERSION}"
    SHA512 8f66674d3b840c76a432bac55dbee6d2124479dcab5b65009651978166b28e3273e1664e4442f27e010c642cf93407bf2e9ef9bd6da45f3b4dc50da0b714f770
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
