vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxcb
    REF  4b40b44cb6d088b6ffa2fb5cf3ad8f12da588cef #v1.14
    SHA512 bd600b9e321f39758bf32582933b4167d335af74acd7312ecc1072bc8df3f511b4f7a85ead3075b73449a3167764cd0fc77f799a86dfe42012f94a4d20a20bd7
    HEAD_REF master # branch name
    PATCHES makefile.patch #without the patch target xproto.c is missing target XCBPROTO_XCBINCLUDEDIR
            #time.patch # missing include 
            build.patch # avoid pulling in conflicting definitions. 
            configure.patch
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
            find_program(XLSTPROC NAMES xsltproc${VCPKG_HOST_EXECUTABLE_SUFFIX} PATHS "${CURRENT_INSTALLED_DIR}/../${HOST_TRIPLET}/tools/libxslt" PATH_SUFFIXES "bin")
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

#if(VCPKG_TARGET_IS_WINDOWS)
#    string(APPEND VCPKG_LINKER_FLAGS_RELEASE " -lpthreadVC3")
#    string(APPEND VCPKG_LINKER_FLAGS_DEBUG " -lpthreadVC3d")
#endif()
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
)

vcpkg_install_make(MAKE_OPTIONS -k --print-data-base)
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES Ws2_32 ws2_32)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(_file "${CURRENT_PACKAGES_DIR}/include/xcb/xkb.h")
    file(READ "${_file}" _contents)
    string(REPLACE "extern xcb_extension_t xcb_xkb_id;" "__declspec(dllimport) extern xcb_extension_t xcb_xkb_id;" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()