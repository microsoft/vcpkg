set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO e-dant/watcher
    REF "${VERSION}"
    SHA512 fcd4581d29c3d9aa4911edc3fc84d8dcf48ec7e5c5b077bc4c41f1f7d63646cdcf02349281b855415608174173f0b19a922f25b7d679e4536a27808617f18cc8
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
