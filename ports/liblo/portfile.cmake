vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO radarsat1/liblo
    REF c1a51bca21e8535ce77a9daf256f2e74c1a7e80f # 0.32
    SHA512 0
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cmake"
    OPTIONS -DTHREADING=1
)

vcpkg_cmake_install()

# Install needed files into package directory
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/liblo)

vcpkg_copy_tools(TOOL_NAMES oscsend oscdump AUTO_CLEAN)

# Remove unnecessary files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
