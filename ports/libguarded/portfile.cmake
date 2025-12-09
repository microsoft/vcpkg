vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO copperspice/cs_libguarded
    REF 9c1e82f42f228345f3b024bed5d08be643c00f8a
    SHA512 ab690489151f5f8451c63c8a78a89a586950f88d19b6df685d979db9442f36b68db402ae5a6749e75b17ac3e1c06447d2d4803d43f9d373031cc05d9b25770e9
    HEAD_REF master
    PATCHES
        fix-install.patch
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME CsLibGuarded CONFIG_PATH lib/cmake/CsLibGuarded)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
