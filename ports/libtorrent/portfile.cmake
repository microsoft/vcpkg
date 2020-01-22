include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arvidn/libtorrent
    REF libtorrent-1_2_2
    SHA512 34dcf5421dfccbba78bdd30890b9c18b92fdee1a2e1693ada9b55b79a167730093862017581b9251a654b5517011dbe4c46b520b03b78aa86a909457f7edcf2c
    HEAD_REF master
    PATCHES
        add-datetime-to-boost-libs.patch
        add-executor_type.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -Ddeprecated-functions=off
)

vcpkg_install_cmake()

file(READ ${CURRENT_PACKAGES_DIR}/include/libtorrent/aux_/export.hpp EXPORT_H)
string(REPLACE "defined TORRENT_BUILDING_SHARED" "0" EXPORT_H "${EXPORT_H}")
if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(REPLACE "defined TORRENT_LINKING_SHARED" "1" EXPORT_H "${EXPORT_H}")
else()
    string(REPLACE "defined TORRENT_LINKING_SHARED" "0" EXPORT_H "${EXPORT_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/libtorrent/aux_/export.hpp "${EXPORT_H}")

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/LibtorrentRasterbar TARGET_PATH share/libtorrentrasterbar)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libtorrent)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libtorrent/LICENSE ${CURRENT_PACKAGES_DIR}/share/libtorrent/copyright)

# Do not duplicate include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/share/cmake)
