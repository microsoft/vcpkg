if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(PATCHES dllimport.patch)
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libx11
    REF  3a30ada60c5217ada37b143b541c8e6f6284c7fa
    SHA512 441f86ff8293d27459feaa93f85bcd4d02c6bd64fdb4d95199e5ee8a75340c2ce9b0fccd0b05840ce0de30ff3af3d21e6f37c81840e82b37dbddf082911b585d
    HEAD_REF master
    PATCHES
        optimize-configure.patch
        cl.build.patch
        io_include.patch
        ${PATCHES}
        vcxserver.patch
        add_dl_pc.patch
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

set(OPTIONS "")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(ENV{CPP} "cl_cpp_wrapper")
    list(APPEND OPTIONS 
                --enable-loadable-i18n=no #Pointer conversion errors
                --enable-unix-transport=no
                --disable-thread-safety-constructor
                ac_cv_search_dlopen=no
    )
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS 
        --enable-malloc0returnsnull=yes      #Configure fails to run the test for some reason
        --enable-ipv6
        --enable-hyperv
        --enable-tcp-transport
        --with-launchd=no
        --with-lint=no
        --disable-selective-werror
        )
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

if(VCPKG_CROSSCOMPILING)
    file(GLOB FOR_BUILD_FILES "${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}/*")
    file(COPY ${FOR_BUILD_FILES} DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/util")
    if(NOT VCPKG_BUILD_TYPE)
        file(COPY ${FOR_BUILD_FILES} DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/util")
    endif()
endif()
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

if(EXISTS "${CURRENT_INSTALLED_DIR}/include/X11/extensions/XKBgeom.h")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/X11/extensions/") #XKBgeom.h should be the only file in there
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if(NOT VCPKG_CROSSCOMPILING)
    file(READ "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/config.log" config_contents)
    string(REGEX MATCH "ac_cv_objext=[^\n]+" objsuffix "${config_contents}")
    string(REPLACE "ac_cv_objext=" "." objsuffix "${objsuffix}")
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/util/makekeys${VCPKG_TARGET_EXECUTABLE_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/util/makekeys${objsuffix}" DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
endif()

endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
    "${CURRENT_PACKAGES_DIR}/share/x11/vcpkg-cmake-wrapper.cmake" @ONLY)

