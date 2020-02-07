
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xorg/xserver
    REF  489f4191f3c881c6c8acce97ec612167a4ae0f33 #v1.20.7
    SHA512 30c15c0f7bfca635118dd9b4ca615b6d79d005880108415dc46b561c7f08b648c231b7f5c498c74ecaa1815cfa81c23f7ba39f6d0c0cdfddaf00104df8741b27
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

if(WIN32)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES pkg-config)
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
    PKG_CONFIG_PATHS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig"
    PKG_CONFIG_PATHS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig"
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
