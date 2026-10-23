vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yoctopuce/yoctolib_cpp
    REF "v${VERSION}"
    SHA512 14f0db4c182f6a584959e3f4d2256928eab52072ee70d0771b5a045a5a7ba76749f6596b1ec33d4922c811de5da6ff79b65ef25450418a251b7bf728d3a220e0
    HEAD_REF master
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
