vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-tao/drogon
    REF v1.0.0-beta21
    SHA512 bacd3c0d20c9d5eb22e6c872c8bea6865a6beb93d83165e117b11a30b7fffd65de48838b599cda81043e7ae1394a9d13390910baa4b84d8cfad3050f152a4c36
    HEAD_REF master
    PATCHES
        vcpkg.patch
        pg.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

# Fix CMake files
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Drogon)
# Copy drogon_ctl
vcpkg_copy_tools(TOOL_NAMES drogon_ctl
                 AUTO_CLEAN)
# # Remove includes in debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Copy pdb files
vcpkg_copy_pdbs()

