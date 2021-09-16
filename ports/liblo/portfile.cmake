vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO radarsat1/liblo
    REF 840ed69b1d669a1ce587eb592746e3dff6985d76 # 0.31
    SHA512 c84ab8ac874595df29fd121fff6ddaa670bcc31e7ca4e5cc0f35092032c9f648cd890bc7eea0152af87b842f8cc7804505ac84a13bac8a5d40e43039efa4aa2d
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cmake
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DTHREADING=1
)

vcpkg_install_cmake()

# Install needed files into package directory
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/liblo)

vcpkg_copy_tools(TOOL_NAMES oscsend oscdump AUTO_CLEAN)

# Remove unnecessary files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblo RENAME copyright)
