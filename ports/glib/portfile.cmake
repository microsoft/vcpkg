# Glib uses winapi functions not available in WindowsStore
vcpkg_fail_port_install(ON_TARGET "UWP")

# Glib relies on DllMain on Windows
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

set(GLIB_VERSION 2.64.2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/gnome/sources/glib/2.64/glib-${GLIB_VERSION}.tar.xz"
    FILENAME "glib-${GLIB_VERSION}.tar.xz"
    SHA512 c65adb76f4a03c19f2df186dde49724135975ec6cd059efca5d753e7459f77925657b1fb6fc4ff0d09b2461b2f6e58c9710fc8cde0a5d648ba0d68ccfef1ec57)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${GLIB_VERSION}
    PATCHES
        #use-libiconv-on-windows.patch
        #arm64-defines.patch
        #fix-arm-builds.patch
)

#file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
#file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake DESTINATION ${SOURCE_PATH})
#file(REMOVE_RECURSE ${SOURCE_PATH}/glib/pcre)
#file(WRITE ${SOURCE_PATH}/glib/pcre/Makefile.in)
#file(REMOVE ${SOURCE_PATH}/glib/win_iconv.c)

if (selinux IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_WINDOWS AND NOT EXISTS "/usr/include/selinux")
    message("Selinux was not found in its typical system location. Your build may fail. You can install Selinux with \"apt-get install selinux\".")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    selinux HAVE_SELINUX
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    #PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DGLIB_VERSION=${GLIB_VERSION}
    OPTIONS_DEBUG
        -DGLIB_SKIP_HEADERS=ON
        -DGLIB_SKIP_TOOLS=ON
)

vcpkg_install_meson()
vcpkg_fixup_meson_targets(CONFIG_PATH share/unofficial-glib TARGET_PATH share/unofficial-glib)

vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
