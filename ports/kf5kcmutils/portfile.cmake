vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kcmutils
    REF "v${VERSION}"
    SHA512 f5a22a0e662f1f3874c50b19ff770f2fa4fed53163eb7b732c8b8529424222a1b5f6908cf712c8feb6bc4984c687c51ded2cd228b01f1732d2d2c7cfba7e8f99
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5KCMUtils)
vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES kcmdesktopfilegenerator
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
