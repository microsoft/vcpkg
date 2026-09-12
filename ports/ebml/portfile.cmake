vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Matroska-Org/libebml
    REF "release-${VERSION}"
    SHA512 8fd3a237be244a5305753341f3ab038a2462d463e2d15753791e08a32ff230d56f614993450315bbfe8e6f7c51a5d1f531fcdf00923d60565bd5b7cd6c840a25
    HEAD_REF master
    PATCHES
        find_dependency.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/EBML)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.LGPL"
)
