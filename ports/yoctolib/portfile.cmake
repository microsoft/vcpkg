vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yoctopuce/yoctolib_cpp
    REF "v${VERSION}"
    SHA512 ed405d77c05288e123851a79e86beaf9778cce487c5d5d4a556f47b3a690517e71b004e5b3e0ae5532cb24ed46a1c04ce4f18c34cccf475fc1ca45a331808c43
    HEAD_REF master
    PATCHES
        001-cmake_config.patch
)

if(VCPKG_TARGET_IS_LINUX)
    vcpkg_find_acquire_program(PKGCONFIG)
    set(ENV{PKG_CONFIG} "${PKGCONFIG}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/Sources"
    OPTIONS
        -DVERSION=${VERSION}
        -DCMAKE_INSTALL_INCLUDEDIR=include/yoctolib
        -DUSE_YSSL=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME yoctolib)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README.md")
