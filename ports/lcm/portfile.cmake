vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lcm-proj/lcm
    REF "v${VERSION}"
    SHA512 a19800c1ac79b7725f26fd1e2e5abedcfcbe1b197a8a48860dd50a7b3e3af658286fe7dd3a1e3c69920eccf2a73185c90bf1cd6cf0f05a405abfa9d8f33eae4c
    HEAD_REF master
    PATCHES 
        only-install-one-flavor.patch
        fix-build-error.patch
        glib.link.patch
        disable-docs.patch
)

vcpkg_cmake_configure(
     SOURCE_PATH "${SOURCE_PATH}"
     OPTIONS
        -DLCM_ENABLE_JAVA=OFF
        -DLCM_ENABLE_LUA=OFF
        -DLCM_ENABLE_PYTHON=OFF
        -DLCM_ENABLE_GO=OFF
        -DLCM_ENABLE_TESTS=OFF
        -DLCM_ENABLE_EXAMPLES=OFF
        -DLCM_INSTALL_M4MACROS=OFF
        -DLCM_INSTALL_PKGCONFIG=OFF
)

vcpkg_cmake_install()
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/lcm/cmake)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/lcm" "${CURRENT_PACKAGES_DIR}/lib/lcm")
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")

vcpkg_copy_tools(TOOL_NAMES lcm-gen lcm-logger lcm-logplayer AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
