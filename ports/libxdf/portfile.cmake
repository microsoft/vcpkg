vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xdf-modules/libxdf
    REF "v${VERSION}"
    SHA512 a4d262b498243ce5021e6778ee84fcbb38f1dd2f4d36037565d3eeead63b8b4fd5b593a358a22c0b0a38d414497307c6d6782929cebe0b65e31d1fee834f5148
    HEAD_REF main
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
