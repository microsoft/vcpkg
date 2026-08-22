vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lcm-proj/lcm
    REF "v${VERSION}"
    SHA512 3da9739a03769e609d44a93ae0f6790a604ca05c93639860bdc67843738452894582ca5eccabc3ade61afe519f40d3147f6bf2fe6ec5abcb03c8dd74dd22fb9c
    HEAD_REF master
    PATCHES 
        only-install-one-flavor.patch
        glib.link.patch
        disable-docs.patch
)

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
