vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO copperspice/cs_libguarded
    REF libguarded-${VERSION}
    SHA512 0dd0b77bc373e764f88a81f0a5c74e8891c306433b9fc5ec3f5b125194d32782496527b9d59ea565a85a0d7a2fdbe510da0a7e1f868e39dc9582ad1d49513f1b
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
