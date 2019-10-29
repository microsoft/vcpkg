#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/uvw
    REF 337bd035a84969a90e1460b480dc4d03d37b7ed1 # v2.2.0_libuv-v1.33
    SHA512 0d682afb8397625fad4d8303a6fbc8e58c28db90bb47cd8dcc66d3c3b3999f5c9fa66bbea5b0c13835b153aa044aab3f02a6e77ea2f89118ec53944ab15c3168
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
