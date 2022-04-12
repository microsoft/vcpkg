# Glib relies on DllMain on Windows
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
    #remove if merged: https://gitlab.gnome.org/GNOME/glib/-/merge_requests/1655
endif()

set(GLIB_MAJOR_MINOR 2.70)
set(GLIB_PATCH 5)
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/gnome/sources/glib/${GLIB_MAJOR_MINOR}/glib-${GLIB_MAJOR_MINOR}.${GLIB_PATCH}.tar.xz"
    FILENAME "glib-${GLIB_MAJOR_MINOR}.${GLIB_PATCH}.tar.xz"
    SHA512 3dfb45a9b6fe67fcf185f5cbb3985b6f1da17caf9c6f01e638d8fe4a6271ea1a30b0cf4ca8f43728bd29a8ac13b05a34e1cf262ade7795f0c0d0a2c0b90b1ff8)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${GLIB_VERSION}
    PATCHES
        use-libiconv-on-windows.patch
        libintl.patch
)


if (selinux IN_LIST FEATURES)
    if(NOT VCPKG_TARGET_IS_WINDOWS AND NOT EXISTS "/usr/include/selinux")
        message("Selinux was not found in its typical system location. Your build may fail. You can install Selinux with \"apt-get install selinux\".")
    endif()
    list(APPEND OPTIONS -Dselinux=enabled)
else()
    list(APPEND OPTIONS -Dselinux=disabled)
endif()

if (libmount IN_LIST FEATURES)
    list(APPEND OPTIONS -Dlibmount=enabled)
else()
    list(APPEND OPTIONS -Dlibmount=disabled)
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS -Diconv=external)
endif()

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dinstalled_tests=false
        ${OPTIONS}
        -Dtests=false
        -Dxattr=false
        -Dlibelf=disabled
)

vcpkg_install_meson(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()

set(GLIB_TOOLS  gdbus
                gio
                gio-querymodules
                glib-compile-resources
                glib-compile-schemas
                gobject-query
                gresource
                gsettings
                )

if(NOT VCPKG_TARGET_IS_WINDOWS)
    if(NOT VCPKG_TARGET_IS_OSX)
        list(APPEND GLIB_TOOLS gapplication)
    endif()
    list(APPEND GLIB_TOOLS glib-gettextize gtester)
endif()
set(GLIB_SCRIPTS gdbus-codegen glib-genmarshal glib-mkenums gtester-report)


if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE MATCHES "x64|arm64")
    list(APPEND GLIB_TOOLS  gspawn-win64-helper${VCPKG_EXECUTABLE_SUFFIX}
                            gspawn-win64-helper-console${VCPKG_EXECUTABLE_SUFFIX})
elseif(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    list(APPEND GLIB_TOOLS  gspawn-win32-helper${VCPKG_EXECUTABLE_SUFFIX}
                            gspawn-win32-helper-console${VCPKG_EXECUTABLE_SUFFIX})
endif()
vcpkg_copy_tools(TOOL_NAMES ${GLIB_TOOLS} AUTO_CLEAN)
foreach(script IN LISTS GLIB_SCRIPTS)
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${script}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${script}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${script}")
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

IF(VCPKG_TARGET_IS_WINDOWS)
    set(SYSTEM_LIBRARIES dnsapi iphlpapi winmm lshlwapi)
else()
    set(SYSTEM_LIBRARIES resolv mount blkid selinux)
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gio-2.0.pc")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gio-2.0.pc" "\${bindir}" "\${bindir}/../tools/${PORT}")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gio-2.0.pc")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gio-2.0.pc" "\${bindir}" "\${bindir}/../../tools/${PORT}")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/glib-2.0.pc")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/glib-2.0.pc" "\${bindir}" "\${bindir}/../tools/${PORT}")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/glib-2.0.pc")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/glib-2.0.pc" "\${bindir}" "\${bindir}/../../tools/${PORT}")
endif()
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES ${SYSTEM_LIBRARIES})

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Fix python scripts
set(_file "${CURRENT_PACKAGES_DIR}/tools/${PORT}/gdbus-codegen")
file(READ "${_file}" _contents)
string(REPLACE "elif os.path.basename(filedir) == 'bin':" "elif os.path.basename(filedir) == 'tools':" _contents "${_contents}")
string(REPLACE "path = os.path.join(filedir, '..', 'share', 'glib-2.0')" "path = os.path.join(filedir, '../..', 'share', 'glib-2.0')" _contents "${_contents}")
string(REPLACE "path = os.path.join(filedir, '..')" "path = os.path.join(filedir, '../../share/glib-2.0')" _contents "${_contents}")
string(REPLACE "path = os.path.join('${CURRENT_PACKAGES_DIR}/share', 'glib-2.0')" "path = os.path.join('unuseable/share', 'glib-2.0')" _contents "${_contents}")

file(WRITE "${_file}" "${_contents}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/gdb")
if(EXISTS "${CURRENT_PACKAGES_DIR}/tools/glib/glib-gettextize")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/glib/glib-gettextize" "${CURRENT_PACKAGES_DIR}" "`dirname $0`/../..")
endif()
