vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://code.videolan.org/
    REPO videolan/libdvdnav
    REF ${VERSION}
    SHA512 080814c30f193176393bf6d4496a1e815b3b288cd102201ba177a13a46f733e1e0b5e05d6ca169e902c669d6f3567926c97e5a20a6712ed5620dcb10c3c3a022
    HEAD_REF master
    PATCHES
        msvc.diff
        no-undefined.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/msvc/include/inttypes.h")

vcpkg_find_acquire_program(PKGCONFIG)
cmake_path(GET PKGCONFIG PARENT_PATH pkgconfig_dir)
vcpkg_add_to_path("${pkgconfig_dir}")

set(cppflags "")
if(VCPKG_TARGET_IS_WINDOWS)
    # PATH_MAX from msvc/libdvdcss.vcxproj
    set(cppflags "CPPFLAGS=\$CPPFLAGS -DPATH_MAX=2048 -DWIN32_LEAN_AND_MEAN")
    if(NOT VCPKG_TARGET_IS_MINGW)
        cmake_path(RELATIVE_PATH SOURCE_PATH BASE_DIRECTORY "${CURRENT_BUILDTREES_DIR}" OUTPUT_VARIABLE sources)
        string(APPEND cppflags " -I../${sources}/msvc/include -D_CRT_SECURE_NO_WARNINGS")
    endif()
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
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
