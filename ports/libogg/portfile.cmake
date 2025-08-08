vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.xiph.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/ogg
    REF v${VERSION}
    SHA512 c41b71a0fcedd97251d01e1a61fd94f6185b2ab0fba96c38e878d354b488b0e9a9a9782674bc06f08c281681c3ddd775be704685d3f6a65131096caa46f261ba
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
