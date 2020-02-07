if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(PATCHES meson.build.patch)
endif()
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xorg/xserver
    REF  489f4191f3c881c6c8acce97ec612167a4ae0f33 #v1.20.7
    SHA512 30c15c0f7bfca635118dd9b4ca615b6d79d005880108415dc46b561c7f08b648c231b7f5c498c74ecaa1815cfa81c23f7ba39f6d0c0cdfddaf00104df8741b27
    HEAD_REF master # branch name
    PATCHES ${PATCHES} #patch name
) 
#fix bzip pkgconfig
#fix freetype pkgconfig
#fix libpngs
set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

if(WIN32)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES pkg-config)
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
endif()
#export LDFLAGS="-Wl,--copy-dt-needed-entries"
vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -Dxnest=false # multiple definition error with it. 
#    /mnt/d/xlinux/installed/x64-linux/lib/libX11.a(XKBGAlloc.o): In function `XkbFreeGeomOverlayKeys':
#   XKBGAlloc.c:(.text+0x5f4): multiple definition of `XkbFreeGeomOverlayKeys'
    PKG_CONFIG_PATHS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig"
    PKG_CONFIG_PATHS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig"
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
set(TOOLS cvt gtf Xorg Xvfb Xwayland Xwin)
foreach(_tool ${TOOLS})
    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    endif()
endforeach()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()