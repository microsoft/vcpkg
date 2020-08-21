vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO proto/xorgproto
    REF c62e8203402cafafa5ba0357b6d1c019156c9f36 # 2020.1
    SHA512 7a18c8ef2da85d235cf9bdc7f0d8aeb914e65af992c189ec91234ea56394d22fa26b27237bc10e91aae051188afb90f3d23f10fa27d68b9f1cbaf6832a21118f
    HEAD_REF master # branch name
    PATCHES 
        xmd.h.patch #patch name
        windows-long64.patch
        windows_mean_and_lean.patch
        #winsock2.patch # include winsock2.h before windows.h
        configure_msys.patch
        #xwindows.patch #TODO: Redo these patches to be less intrusive
        #xwinsock.patch #TODO: Redo these patches to be less intrusive
        xwin.patch # REDID the above two but a bit more minimal
        xmd_bool.patch
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(OPTIONS --enable-legacy) # has an build error on windows so I assume it is unsupported on windows. 
endif()

if(NOT XLSTPROC)
    if(WIN32)
        set(HOST_TRIPLETS x64-windows x64-windows-static x86-windows x86-windows-static)
    elseif(APPLE)
        set(HOST_TRIPLETS x64-osx)
    elseif(UNIX)
        set(HOST_TRIPLETS x64-linux)
    endif()
        foreach(HOST_TRIPLET ${HOST_TRIPLETS})
            find_program(XLSTPROC NAMES xsltproc${VCPKG_HOST_EXECUTABLE_SUFFIX} PATHS "${CURRENT_INSTALLED_DIR}/../${HOST_TRIPLET}/tools/libxslt" "${CURRENT_INSTALLED_DIR}/../${HOST_TRIPLET}/tools/libxslt/bin")
            if(XLSTPROC)
                break()
            endif()
        endforeach()
endif()
if(NOT XLSTPROC)
    message(FATAL_ERROR "${PORT} requires xlstproc for the host system. Please install libxslt within vcpkg or your system package manager!")
endif()
get_filename_component(XLSTPROC_DIR "${XLSTPROC}" DIRECTORY)
file(TO_NATIVE_PATH "${XLSTPROC_DIR}" XLSTPROC_DIR_NATIVE)
vcpkg_add_to_path("${XLSTPROC_DIR}")
set(ENV{XSLTPROC} ${XLSTPROC})
vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    #SKIP_CONFIGURE
    #NO_DEBUG
    #AUTO_HOST
    #AUTO_DST
    #PRERUN_SHELL "export ACLOCAL=\"aclocal -I ${CURRENT_INSTALLED_DIR}/share/xorg-macros/aclocal/\""
    OPTIONS ${OPTIONS} --with-xmlto=no --with-fop=no
    #OPTIONS_DEBUG
    #OPTIONS_RELEASE
)

vcpkg_install_make()
list(APPEND IGNORED_LIBRARIES Xau Xt xt SM ICE X11 xcb Xdmcp pthread)
# xproto install a few .pc files with not yet available packages/libraries. 

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}/pkgconfig/")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}/pkgconfig/" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/share/${PORT}/pkgconfig/")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/")
    file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/pkgconfig/" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
endif()
vcpkg_fixup_pkgconfig(SKIP_CHECK SYSTEM_LIBRARIES ${IGNORED_LIBRARIES}) 
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# # Handle copyright
file(GLOB_RECURSE _files "${SOURCE_PATH}/COPYING*")
file(INSTALL ${_files} DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")

file(REMOVE "${CURRENT_PACKAGES_DIR}/include/X11/extensions/vldXvMC.h") #duplicate with xmvc

