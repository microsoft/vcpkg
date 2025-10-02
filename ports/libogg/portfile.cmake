vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/ogg
    REF v${VERSION}
    SHA512 c247e1da8b12f8b33272fafb6d7c171a1a2687c3632977439fa60b96ccc2ad751d88a2931bb3e18e1ddf2eea2e82cdd0aab087b2ec5393a9228c703476fa0167
    HEAD_REF master
)

if(VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string("${SOURCE_PATH}/win32/ogg.def" "LIBRARY ogg" "LIBRARY libogg")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 #https://gitlab.xiph.org/xiph/ogg/-/issues/2304
        -DINSTALL_DOCS=OFF
        -DINSTALL_PKG_CONFIG_MODULE=ON
        -DBUILD_TESTING=OFF
    MAYBE_UNUSED_VARIABLES
        CMAKE_POLICY_VERSION_MINIMUM
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Ogg PACKAGE_NAME ogg)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
