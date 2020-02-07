## requires AUTOCONF, LIBTOOL and PKCONF

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxcb
    REF  8287ebd7b752c33b0cabc4982606fe4831106f7e #v1.13.1 
    SHA512 625939b67d129f681503a2f784daa75897b31b09daba0b9ea72457c9dffdab34a644c0b73068282de01ddfdcd5fc29242e4db5367d39b795984374846c1319c8
    HEAD_REF master # branch name
    PATCHES makefile.patch #without the patch target xproto.c is missing target XCBPROTO_XCBINCLUDEDIR
            time.patch # missing include 
           # windefs.patch # avoid pulling in conflicting definitions. 
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")
if(VCPKG_TARGET_IS_WINDOWS)
    set(OPTIONS --disable-dependency-tracking)
endif()

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
file(TO_NATIVE_PATH "${PYTHON3_DIR}" PYTHON3_DIR_NATIVE)
vcpkg_add_to_path("${PYTHON3_DIR}")

#vcpkg_find_acquire_program(XLSTPROC)
if(NOT XLSTPROC)
    if(WIN32)
        set(HOST_TRIPLETS x64-windows x64-windows-static x86-windows x86-windows-static)
    elseif(APPLE)
        set(HOST_TRIPLETS x64-osx)
    elseif(UNIX)
        set(HOST_TRIPLETS x64-linux)
    endif()
        foreach(HOST_TRIPLET ${HOST_TRIPLETS})
            find_program(XLSTPROC NAMES xsltproc${VCPKG_HOST_EXECUTABLE_SUFFIX} PATHS "${CURRENT_INSTALLED_DIR}/../${HOST_TRIPLET}/tools/libxslt")
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
set(ENV{XLSTPROC} "${XLSTPROC}")

get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
file(TO_NATIVE_PATH "${PYTHON3_DIR}" PYTHON3_DIR_NATIVE)

vcpkg_add_to_path("${PYTHON3_DIR}")
set(ENV{PYTHONPATH} "$ENV{PYTHONPATH}${VCPKG_HOST_PATH_SEPARATOR}${CURRENT_INSTALLED_DIR}/lib/python3.7/site-packages/")

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    #SKIP_CONFIGURE
    #NO_DEBUG
    #AUTO_HOST
    #AUTO_DST
    #PRERUN_SHELL ${SHELL_PATH}
    OPTIONS ${OPTIONS}
    #OPTIONS_DEBUG
    #OPTIONS_RELEASE
    PKG_CONFIG_PATHS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig"
    PKG_CONFIG_PATHS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig"
)

vcpkg_install_make(MAKE_OPTIONS -k --print-data-base)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
