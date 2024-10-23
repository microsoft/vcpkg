vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://code.videolan.org/
    REPO videolan/libdvdcss
    REF ${VERSION}
    SHA512 b4265ea7c31ca863569b6b20caf158d7ecf9ef6ca8ea3fb372ab7a730e2cb0fdfc2331e6b7aba102faa7751301e063f466dc5dc50a467dd659e008ee7c73383a
    HEAD_REF master
)
file(WRITE "${SOURCE_PATH}/ChangeLog" "Cf. https://code.videolan.org/videolan/libdvdcss/-/commits/${VERSION}/") # not in git

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
