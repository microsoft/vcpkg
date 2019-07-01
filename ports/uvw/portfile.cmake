#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/uvw
    REF v1.17.0_libuv-v1.29
    SHA512 2e3ee6e55950185e1889c99b07d63d811d89ad20705253ad699a828073f5ea7860616e0ae980232c7819d3fd21a4cb7a2e9d084fd8c4f40b19951106f08b9ad0
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/uvw-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/uvw/)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright/readme/package files
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/uvw RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/uvw)
