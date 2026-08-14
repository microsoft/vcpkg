vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/libvpl
    REF "v${VERSION}"
    SHA512 4bf891a575541412b1f07d3ac85550e66026bc513996ad76685cb222eb312c496de8bd2a4715739f377dcd2650e91a998b66ef0383f74741a7d7422ffd7b56fa
    HEAD_REF main
    PATCHES
        001-fix-pkgconfig.patch
        002-fix-cmake-config.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_MSVC_STATIC_RUNTIME)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_MSVC_STATIC_RUNTIME=${USE_MSVC_STATIC_RUNTIME}
        -DBUILD_TESTS=OFF
        -DINSTALL_EXAMPLES=OFF
        -DBUILD_EXAMPLES=OFF
        -DINSTALL_DEV=ON
        -DINSTALL_LIB=ON
        -DCMAKE_INSTALL_LIBDIR=lib
        -DCMAKE_INSTALL_BINDIR=bin
        "-DVPL_INSTALL_LICENSEDIR=${CURRENT_PACKAGES_DIR}/share/copyright_tmp"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/vpl" PACKAGE_NAME VPL)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if(VCPKG_TARGET_IS_WINDOWS
    AND EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/vpl.pc"
    AND EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/vpld.lib")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/vpl.pc" " -lvpl" " -lvpld")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/etc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/etc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/copyright_tmp")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
