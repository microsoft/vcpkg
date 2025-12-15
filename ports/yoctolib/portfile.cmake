vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yoctopuce/yoctolib_cpp
    REF "v${VERSION}"
    SHA512 c57baae00289dc2bbcabe278d9ff5667077bd3b93fadd20fd9de4428050af0bb6a659849b52e5c93b3e51c6d71764839c0d299e775d4133f85fa31990242077e
    HEAD_REF master
    PATCHES
        001-cmake_config.patch
        002-add_missing_win32_bcrypt_linkage.patch
        003-fix_win32_shared_build.patch
)

set(OPTIONS "-DUSE_YSSL=OFF")
if(VCPKG_TARGET_IS_LINUX)
    vcpkg_find_acquire_program(PKGCONFIG)
    list(APPEND OPTIONS "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/Sources"
    OPTIONS
        ${OPTIONS}
        -DVERSION=${VERSION}
        -DCMAKE_INSTALL_INCLUDEDIR=include/yoctolib
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-yoctolib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README.md")
