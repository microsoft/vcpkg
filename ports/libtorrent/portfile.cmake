include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arvidn/libtorrent
    REF libtorrent_1_2_0
    SHA512 2dae77f32cf3da388edece7e64b8d9cf359cca735a101d96bb18fb06573fd1d84c303e5bebd370f637d7c73010ea2d99e38748b2259ce02ae8f0dbc0c4f01518
    HEAD_REF master
    PATCHES add-datetime-to-boost-libs.patch
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
