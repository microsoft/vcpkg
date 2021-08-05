vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commonmark/cmark
    REF 8800e66010214384e75f933830ca5585e1ae3060    #0.30.0
    SHA512 9055eb13212034fe1a819ae697a74fa927a5094dc38da9548758b7a2b07834f6b85b71718f5c96cef9676b244243b0c0b5173f672f8d823df1bdff318bfd0ebf
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

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_tools(TOOL_NAMES cmark_exe AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT EXISTS ${CURRENT_PACKAGES_DIR}/bin/cmark)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/cmark.exe ${CURRENT_PACKAGES_DIR}/debug/bin/cmark.exe)
endif()
