vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xdf-modules/libxdf
    REF "v${VERSION}"
    SHA512 81ff3598442d3ea166ec54b74248ad7b7eca5fcfdb72526978966398ad9e6524883183e71b68e349c46c2705779bf2b4922ce097f01afe7a62faa449ab8fa075
    HEAD_REF main
    PATCHES
        fix-pugixml-dependency.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DXDF_NO_SYSTEM_PUGIXML=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
