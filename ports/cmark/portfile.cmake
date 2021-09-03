vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commonmark/cmark
    REF 977b128291c0cf6c5053cdcf2ac72e627f09c105    #0.30.1
    SHA512 ff8139fbb45549d6bea70e11c35ae1d8cf6108d0141688cc2b878afa6247147e0c15ac885e6ed8fa2263534dc79e88e398b30d3d3ae800f13dcdd878114adac8
    HEAD_REF master
    PATCHES
        rename-shared-lib.patch
        fix-uwp-APPX0703.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" CMARK_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" CMARK_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DCMARK_TESTS=OFF
        -DCMARK_SHARED=${CMARK_SHARED}
        -DCMARK_STATIC=${CMARK_STATIC}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cmark)

vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES cmark_exe AUTO_CLEAN)

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT EXISTS ${CURRENT_PACKAGES_DIR}/bin/cmark)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()