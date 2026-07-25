vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gulrak/filesystem
    REF "v${VERSION}"
    HEAD_REF master
    SHA512 f3b798e3c1cf339c822af3c58a9b3692bd75b95d236e9a441ce61178257103f7903dbca8b94de595cb7a4e60539e1f7ec55ad424c76f9016f5329947d05df45a
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGHC_FILESYSTEM_BUILD_TESTING=OFF
        -DGHC_FILESYSTEM_BUILD_EXAMPLES=OFF
        -DGHC_FILESYSTEM_WITH_INSTALL=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ghc_filesystem
    CONFIG_PATH "lib/cmake/ghc_filesystem"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
