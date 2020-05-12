# Glib uses winapi functions not available in WindowsStore
vcpkg_fail_port_install(ON_TARGET "UWP")

# Glib relies on DllMain on Windows
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

set(GLIB_VERSION 2.52.3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/gnome/sources/glib/2.52/glib-${GLIB_VERSION}.tar.xz"
    FILENAME "glib-${GLIB_VERSION}.tar.xz"
    SHA512 a068f2519cfb82de8d4b7f004e7c1f15e841cad4046430a83b02b359d011e0c4077cdff447a1687ed7c68f1a11b4cf66b9ed9fc23ab5f0c7c6be84eb0ddc3017)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${GLIB_VERSION}
    PATCHES
        use-libiconv-on-windows.patch
        arm64-defines.patch
        fix-arm-builds.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake DESTINATION ${SOURCE_PATH})
file(REMOVE_RECURSE ${SOURCE_PATH}/glib/pcre)
file(WRITE ${SOURCE_PATH}/glib/pcre/Makefile.in)
file(REMOVE ${SOURCE_PATH}/glib/win_iconv.c)

if (selinux IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_WINDOWS AND NOT EXISTS "/usr/include/selinux")
    message("Selinux was not found in its typical system location. Your build may fail. You can install Selinux with \"apt-get install selinux\".")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    selinux HAVE_SELINUX
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DGLIB_VERSION=${GLIB_VERSION}
    OPTIONS_DEBUG
        -DGLIB_SKIP_HEADERS=ON
        -DGLIB_SKIP_TOOLS=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-glib TARGET_PATH share/unofficial-glib)

vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
if(VCPKG_LIBRARY_LINKAGE STREQUAL STATIC)
    set(_p0 ".0")
else()    
    set(_p0)
endif()
vcpkg_pkgconfig(NAME glib-2.0 COMMON -lglib-2${_p0} REQUIRES zlib libpcre)
vcpkg_pkgconfig(NAME gmodule-2.0 COMMON -lgmodule-2${_p0} REQUIRES glib-2.0)
vcpkg_pkgconfig(NAME gobject-2.0 COMMON -lgobject-2${_p0} REQUIRES glib-2.0 libffi)
vcpkg_pkgconfig(NAME gthread-2.0 COMMON -lgthread-2${_p0} REQUIRES glib-2.0)
vcpkg_pkgconfig(NAME gio-2.0 COMMON -lgio-2${_p0} REQUIRES gobject-2.0 gmodule-2.0)
