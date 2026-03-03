vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hesphoros/UniConv
    REF "v${VERSION}"
    SHA512 db0bd4c4408dc26e0a690e140d8bfb826baf8f42a53b1829942f49dad1ba85626d56920090a9e58fce037ef109225fc3f45ab4e9ebba6968546b0397a073a334
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" UNICONV_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNICONV_BUILD_SHARED=${UNICONV_BUILD_SHARED}
        -DUNICONV_BUILD_TESTS=OFF
        -DUNICONV_LIBICONV_SOURCE=SYSTEM
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DFETCHCONTENT_FULLY_DISCONNECTED=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME UniConv
    CONFIG_PATH lib/cmake/UniConv
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
