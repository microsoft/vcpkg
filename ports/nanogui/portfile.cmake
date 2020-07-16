vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "uwp" )

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mitsuba-renderer/nanogui
    REF 21e5cbc880b2e26b28b2a35085a9e6706da1e2a8
    SHA512 7eb356f0b589137f542db4b5b631071459ba367cd9db962e72edb19c1dbdbf37b4c93216152563bc23aae74fe6af2c2c859409a05234b26f2d29149622119d42
    HEAD_REF master
    PATCHES
      fix-cmakelists.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTION
        -DNANOGUI_BUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
