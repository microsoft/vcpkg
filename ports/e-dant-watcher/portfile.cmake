set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO e-dant/watcher
    REF "${VERSION}"
    SHA512 94f4a7074598ca490db4e2171eafa4cfc7a1d9a6107c3e24780a4716c84af3e3466030fb21c9b2a56c34ee18d5ec6842f741bcb92e252a45702a2e64945f3450
    HEAD_REF release
    PATCHES
        fix-install.patch
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_LIB=OFF
        -DBUILD_BIN=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

# remove empty lib and debug/lib directories (and duplicate files from debug/include)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license")
