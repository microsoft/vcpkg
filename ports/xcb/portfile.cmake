if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxcb
    REF  ddafdba11f6919e6fcf977c09c78b06f94de47aa #v1.14 + some patches
    SHA512 49e1bf6654814d1513ad8b9142f81fefd43bc939411bf7b2ce9f9fde0961658bec5d1578ca8fd099974898a99a54ff7c6220e58c0d422375d035cd17edbdb072 # bd600b9e321f39758bf32582933b4167d335af74acd7312ecc1072bc8df3f511b4f7a85ead3075b73449a3167764cd0fc77f799a86dfe42012f94a4d20a20bd7
    HEAD_REF master # branch name
    PATCHES makefile.patch # without the patch target xproto.c is missing target XCBPROTO_XCBINCLUDEDIR
            configure.patch 
            use_xwindows_includes.patch # use the X11 include wrappers for windows headers
            getpid_include.patch # add include for getpid on windows
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")
if(VCPKG_TARGET_IS_WINDOWS)
    set(OPTIONS --disable-dependency-tracking)
endif()

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
file(TO_NATIVE_PATH "${PYTHON3_DIR}" PYTHON3_DIR_NATIVE)
vcpkg_add_to_path("${PYTHON3_DIR}")

if(NOT XLSTPROC)
    find_program(XLSTPROC NAMES "xsltproc${VCPKG_HOST_EXECUTABLE_SUFFIX}" PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/libxslt" PATH_SUFFIXES "bin")
endif()
if(NOT XLSTPROC)
    message(FATAL_ERROR "${PORT} requires xlstproc for the host system. Please install libxslt within vcpkg or your system package manager!")
endif()
get_filename_component(XLSTPROC_DIR "${XLSTPROC}" DIRECTORY)
file(TO_NATIVE_PATH "${XLSTPROC_DIR}" XLSTPROC_DIR_NATIVE)
vcpkg_add_to_path("${XLSTPROC_DIR}")
set(ENV{XLSTPROC} "${XLSTPROC}")

if(DEFINED ENV{PYTHONPATH})
    set(ENV{PYTHONPATH} "${CURRENT_INSTALLED_DIR}/tools/python3/site-packages/${VCPKG_HOST_PATH_SEPARATOR}$ENV{PYTHONPATH}")
else()
    set(ENV{PYTHONPATH} "${CURRENT_INSTALLED_DIR}/tools/python3/site-packages/")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS ${OPTIONS}
)

vcpkg_install_make()

set(pcfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/xcb.pc")
if(EXISTS "${pcfile}")
    vcpkg_replace_string("${pcfile}" "Requires: " "Requires: xau xdmcp ")
endif()
set(pcfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/xcb.pc")
if(EXISTS "${pcfile}")
    vcpkg_replace_string("${pcfile}" "Requires: " "Requires: xau xdmcp ")
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND NOT VCPKG_TARGET_IS_MINGW)
    set(extensions 
            bigreq 
            composite
            damage
            dpms
            dri2
            dri3
            ge
            glx
            present
            randr
            record
            render
            res
            screensaver
            shape
            shm
            sync
            xc_misc
            xevie
            xf86dri
            xfixes
            xinerama
            xinput
            xkb
            xprint
            xtest
            xv
            xvmc)
    foreach(ext IN LISTS extensions)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/xcb/${ext}.h"
                     "extern xcb_extension_t"
                     "__declspec(dllimport) extern xcb_extension_t")
    endforeach()
endif()
endif()
