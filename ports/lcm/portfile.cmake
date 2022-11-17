vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lcm-proj/lcm
    REF v1.4.0
    SHA512 ca036aa2c31911e0bfaeab9665188c97726201267314693a1c333c4efe13ea598b39a55a19bc1d48e65462ac9d1716adfda5af86c645d59c3247192631247cc6
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
