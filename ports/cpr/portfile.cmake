vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_TARGET_IS_UWP)
    set(UWP_PATCH fix-uwp.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO whoshuu/cpr
    REF f4622efcb59d84071ae11404ae61bd821c1c344b # v1.6.2
    SHA512 7835b7613529798b5edaefc99c907bbc7144133a1fac62a2c9af09c8c7a09b2ea1864544c4c0385969ad3dc64806b8d258abbcd39add2004ed8428741286ff20
    HEAD_REF master
    PATCHES
        001-cpr-config.patch
        ${UWP_PATCH}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DCPR_BUILD_TESTS=OFF
        -DCPR_FORCE_USE_SYSTEM_CURL=ON
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/cprConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/lib/cmake/cpr)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/cpr)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
