vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gulrak/filesystem
    REF v1.5.12
    HEAD_REF master
    SHA512 2cba74921104fa84547288ff983260ce1e81967df6a7d2a334074826c355c72945ad64e6979cd302a23c5e3a398990706b01fc573c046512e9f508edca9da12c
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
