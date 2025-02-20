vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ph3at/libenvpp
    REF v${VERSION}
    SHA512 6a56a16a4ba0e3fe97dcf4de2fbf8aba17d2e237c9d6daf559599d237a3e89ec951d2aefc845b79758b73a6bb72a2c69fac25d679127027158a1173d561398aa
    HEAD_REF main
    PATCHES
        fix-dependencies.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBENVPP_EXAMPLES=OFF
        -DLIBENVPP_TESTS=OFF
        -DLIBENVPP_CHECKS=OFF
        -DLIBENVPP_INSTALL=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
