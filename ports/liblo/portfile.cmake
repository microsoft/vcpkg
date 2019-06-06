include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO radarsat1/liblo
    REF 0.30
    SHA512 d36c141c513f869e6d1963bd0d584030038019b8be0b27bb9a684722b6e7a38e942ad2ee7c2e67ac13b965560937aad97259435ed86034aa2dc8cb92d23845d8
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

file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/oscsend.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/liblo)
file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/oscdump.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/liblo)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/liblo)

# Remove unnecessary files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/oscsend.exe ${CURRENT_PACKAGES_DIR}/bin/oscdump.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/oscsend.exe ${CURRENT_PACKAGES_DIR}/debug/bin/oscdump.exe)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblo RENAME copyright)
