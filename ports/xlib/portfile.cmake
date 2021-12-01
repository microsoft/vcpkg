if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(PATCHES dllimport.patch)
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libx11
    REF  f906fe8e9769e4313294b68e61c402610ade69da #x11 v 1.7.2
    SHA512 6f9e9e6a4cd3b68f53076e9e232c7e48d5cfc1c6cfacd44bb9262bd94fe601b0558355c1d3065d71fcfaa703071896a67a1140b69eef810e7a8bbbf3af638316
    HEAD_REF master # branch name
    PATCHES cl.build.patch #patch name
            io_include.patch
            ${PATCHES}
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

if(VCPKG_TARGET_IS_WINDOWS)
    set(ENV{CPP} "cl_cpp_wrapper")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    set(OPTIONS 
        --enable-malloc0returnsnull=yes      #Configure fails to run the test for some reason
        --enable-loadable-i18n=no           #Pointer conversion errors
        --enable-ipv6=no
        --with-launchd=no
        --with-lint=no
        --disable-selective-werror
        --enable-unix-transport=no)
endif()
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

if(VCPKG_TARGET_IS_OSX)
    set(ENV{LC_ALL} C)
endif()
vcpkg_find_acquire_program(PERL)
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS 
        ${OPTIONS}
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

if(EXISTS "${CURRENT_INSTALLED_DIR}/include/X11/extensions/XKBgeom.h")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/X11/extensions/") #XKBgeom.h should be the only file in there
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()
