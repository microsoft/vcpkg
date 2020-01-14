# Glib uses winapi functions not available in WindowsStore
vcpkg_fail_port_install(ON_TARGET "UWP")

# Glib relies on DllMain on Windows
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

if (selinux IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_WINDOWS AND NOT EXISTS "/usr/include/selinux")
    message("Selinux was not found in its typical system location. Your build may fail. You can install Selinux with \"apt-get install selinux\".")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    selinux HAVE_SELINUX
)

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

if(VCPKG_TARGET_IS_WINDOWS)
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake DESTINATION ${SOURCE_PATH})
    file(REMOVE_RECURSE ${SOURCE_PATH}/glib/pcre)
    file(WRITE ${SOURCE_PATH}/glib/pcre/Makefile.in)
    file(REMOVE ${SOURCE_PATH}/glib/win_iconv.c)

    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS
            ${FEATURE_OPTIONS}
            -DGLIB_VERSION=${GLIB_VERSION}
        OPTIONS_DEBUG
            -DGLIB_SKIP_HEADERS=ON
            -DGLIB_SKIP_TOOLS=ON
    )

    vcpkg_install_cmake()
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-glib TARGET_PATH share/unofficial-glib)

    vcpkg_copy_pdbs()
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/glib)
else()
    set(ENV{LIBFFI_CFLAGS} "-I${CURRENT_INSTALLED_DIR}/lib/libffi-3.1/include")
    set(ENV{LIBFFI_LIBS} "-L${CURRENT_INSTALLED_DIR}/lib -lffi")

    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            --enable-libmount=no
    )

    vcpkg_install_make()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/gdb)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/gio)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/gio)
    #todo: we should fix tools setup

    vcpkg_fixup_pkgconfig_targets()
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
