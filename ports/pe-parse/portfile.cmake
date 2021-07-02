vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO trailofbits/pe-parse
    REF ff4f8449bf9a04710507b75e6dcef6f156f2ec4c   #v1.3.0
    SHA512 4687e0ffdb84537fa9a2a78a4584d0f8e7cd39ea797d7bbdff2aa40e80e1f87f4230fba0e30c662062a98db6d70f08c524f0203aa86d00bc02088d432b7eacc5
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_COMMAND_LINE_TOOLS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/pe-parse TARGET_PATH share/pe-parse)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(
    INSTALL
    "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/pe-parse"
    RENAME copyright
)
