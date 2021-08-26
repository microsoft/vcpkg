vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO strukturag/libde265
    REF 8aed7472df0af25b811828fa14f2f169dc34d35a # v1.0.8
    SHA512 e2da1436e5b0d8a3841087e879fbbff5a92de4ebb69d097959972ec8c9407305bc2a17020cb46139fbacc84f91ff8cfb4d9547308074ba213e002ee36bb2e006
    HEAD_REF master
    PATCHES
        fix-libde265-headers.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libde265/)
vcpkg_copy_tools(TOOL_NAMES dec265 enc265 AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
