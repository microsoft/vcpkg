include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arvidn/libtorrent
    REF libtorrent-1_1_5
    SHA512 edaff6347bf922af8b6d74e332e180fe122f64152a152fb905f4f2c3371dc29d668fc2b0ffcda3f56b50a1a51b25d1a3ae4284ed6e09f6a2eb7b34bcce8dd9c7
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/add-datetime-to-boost-libs.patch
            ${CMAKE_CURRENT_LIST_DIR}/add-dbghelp-to-win32-libs.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBTORRENT_SHARED)

file(READ "${SOURCE_PATH}/include/libtorrent/export.hpp" _contents)
string(REPLACE "<boost/config/select_compiler_config.hpp>" "<boost/config/detail/select_compiler_config.hpp>" _contents "${_contents}")
string(REPLACE "<boost/config/select_platform_config.hpp>" "<boost/config/detail/select_platform_config.hpp>" _contents "${_contents}")
file(WRITE "${SOURCE_PATH}/include/libtorrent/export.hpp" "${_contents}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -Dshared=${LIBTORRENT_SHARED}
        -Ddeprecated-functions=off
)

vcpkg_install_cmake()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
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
