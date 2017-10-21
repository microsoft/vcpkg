# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libtorrent-libtorrent-1_1_4)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/arvidn/libtorrent/archive/libtorrent-1_1_4.zip"
    FILENAME "libtorrent-1_1_4.zip"
    SHA512 fd3b875c9626721db9b3e719ce50deeb6f39a030df1e23dd421d0b142aac9c3bb7bee3a61f0c18bb30f85d4dd6131fe90d6138c09ba598f09230824f8d5a3fb1
)

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/add-datetime-to-boost-libs.patch
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/add-dbghelp-to-win32-libs.patch
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/vcpkg-boost-madness.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(LIBTORRENT_SHARED ON)
else()
    set(LIBTORRENT_SHARED OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -Dshared=${LIBTORRENT_SHARED}
        -Ddeprecated-functions=off
)

vcpkg_install_cmake()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    # Put shared libraries into the proper directory
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)

    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/torrent-rasterbar.dll ${CURRENT_PACKAGES_DIR}/bin/torrent-rasterbar.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/torrent-rasterbar.dll ${CURRENT_PACKAGES_DIR}/debug/bin/torrent-rasterbar.dll)

    # Defines for shared lib
    file(READ ${CURRENT_PACKAGES_DIR}/include/libtorrent/export.hpp EXPORT_H)
    string(REPLACE "defined TORRENT_BUILDING_SHARED" "1" EXPORT_H "${EXPORT_H}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/libtorrent/export.hpp "${EXPORT_H}")
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libtorrent)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libtorrent/LICENSE ${CURRENT_PACKAGES_DIR}/share/libtorrent/copyright)

# Do not duplicate include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
