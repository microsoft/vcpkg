vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gulrak/filesystem
    REF v1.5.4
    HEAD_REF master
    SHA512 01fb69ce46259d25d152667943c20e013c90e005647ca1c9c64e0721882236079bac160c04b5edf310e1163bdf8cb6fc0343680de686a1329777027008c301bf
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DGHC_FILESYSTEM_BUILD_TESTING=OFF
        -DGHC_FILESYSTEM_BUILD_EXAMPLES=OFF
        -DGHC_FILESYSTEM_WITH_INSTALL=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ghc_filesystem
    CONFIG_PATH lib/cmake/ghc_filesystem
)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug
                    ${CURRENT_PACKAGES_DIR}/lib
)
