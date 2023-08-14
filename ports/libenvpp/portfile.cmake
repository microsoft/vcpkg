vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ph3at/libenvpp
    REF v${VERSION}
    SHA512 d8d2e6405311be1cba47cdf1c8b29018c84716a0d34a18bf3b6fa8c05f5eddf447ddee407a407d765e92296c5d7e7b5f2fe4561fb66f5165826825158ef82fc8
    HEAD_REF main
    PATCHES
        fix-dependencies.patch
        fix-install.patch
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
