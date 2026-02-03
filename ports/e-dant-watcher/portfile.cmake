set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO e-dant/watcher
    REF "${VERSION}"
    SHA512 7f0f95c3f6aa6ee43bf24aa34df25ca82c10041394f32c00b9affc09ea06a466cd37762099eb46e478645b97fc066d68fbad194dc44416b970525cd9c59b3e58
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
