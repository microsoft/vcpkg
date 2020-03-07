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
vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_DIR "${BISON}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

if(WIN32) # WIN32 HOST probably has win_flex and win_bison!
    if(NOT EXISTS "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        file(CREATE_LINK "${FLEX}" "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
    if(NOT EXISTS "${BISON_DIR}/BISON${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        file(CREATE_LINK "${BISON}" "${BISON_DIR}/bison${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
endif()

if("xwayland" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dxwayland=true)
else()
    list(APPEND OPTIONS -Dxwayland=false)
endif()
if("xnest" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dxnest=true)
else()
    list(APPEND OPTIONS -Dxnest=false)
endif()
if("xwin" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dxwin=true)
else()
    list(APPEND OPTIONS -Dxwin=false)
endif()
if("xorg" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dxorg=true)
else()
    list(APPEND OPTIONS -Dxorg=false)
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS -Dglx=false) #Requires Mesa3D for gl.pc
    list(APPEND OPTIONS -Dsecure-rpc=false) #Problem encountered: secure-rpc requested, but neither libtirpc or libc RPC support were found
    list(APPEND OPTIONS -Dxvfb=false) #hw\vfb\meson.build:7:0: ERROR: '' is not a target.
endif()

if(WIN32)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES pkg-config)
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
endif()
#export LDFLAGS="-Wl,--copy-dt-needed-entries"
vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${OPTIONS}
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