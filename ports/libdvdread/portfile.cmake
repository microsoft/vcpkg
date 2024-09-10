vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://code.videolan.org/
    REPO videolan/libdvdread
    REF ${VERSION}
    SHA512 9eb6d551489ab1d214c56461eebafd6ecba7de8dcc60aecb7e22f82c019fd3d045fc09af66507c2e14bc53e099aec8e87620dfd988fe047a7bfa5e5d1d2c46bd
    HEAD_REF master
)
file(WRITE "${SOURCE_PATH}/ChangeLog" "Cf. https://code.videolan.org/videolan/libdvdread/-/commits/${VERSION}/") # not in git

vcpkg_find_acquire_program(PKGCONFIG)
cmake_path(GET PKGCONFIG PARENT_PATH pkgconfig_dir)
vcpkg_add_to_path("${pkgconfig_dir}")

set(cppflags "")
if(VCPKG_TARGET_IS_WINDOWS)
    # PATH_MAX from msvc/libdvdcss.vcxproj
    set(cppflags "CPPFLAGS=\$CPPFLAGS -DPATH_MAX=2048 -DWIN32_LEAN_AND_MEAN")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --disable-doc
        --with-libdvdcss
        ${cppflags}
)
vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
