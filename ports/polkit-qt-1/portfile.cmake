vcpkg_from_gitlab(
    GITLAB_URL https://invent.kde.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libraries/polkit-qt-1
    REF "v${VERSION}"
    SHA512 b0ad001846c149cfc81108894a54bea30efddcf6f34fc115a7874c72bd5079e5c21d2d2c16bbf11c9fabe2443878d9369c311e93afdc810b4bb7c95266f25eef
    HEAD_REF master
)

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TEST=OFF
        -DQT_MAJOR_VERSION=6
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME polkitqt6-1
    CONFIG_PATH lib/cmake/PolkitQt6-1
)
vcpkg_fixup_pkgconfig(SKIP_CHECK)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
