include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arvidn/libtorrent
    REF bcb26fd638bd8c543cd3cc42837b120ff86d44b1
    SHA512 af897d2daca6e67efe777724147b1047624df9df938222fe967d380263d88ccb3c081e1a24a6c790bf1b35f46385ef08b46d8e46d0922f945cd28c59dd0d35a7
    HEAD_REF master
    PATCHES
        add-datetime-to-boost-libs.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBTORRENT_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -Dshared=${LIBTORRENT_SHARED}
        -Ddeprecated-functions=off
)

vcpkg_install_cmake()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    # Defines for shared lib
    file(READ ${CURRENT_PACKAGES_DIR}/include/libtorrent/aux_/export.hpp EXPORT_H)
    string(REPLACE "defined TORRENT_BUILDING_SHARED" "1" EXPORT_H "${EXPORT_H}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/libtorrent/aux_/export.hpp "${EXPORT_H}")
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/LibtorrentRasterbar TARGET_PATH share/libtorrentrasterbar)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libtorrent)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libtorrent/LICENSE ${CURRENT_PACKAGES_DIR}/share/libtorrent/copyright)

# Do not duplicate include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/share/cmake)
