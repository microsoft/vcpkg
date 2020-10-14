vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO whoshuu/cpr
    REF 5e87cb5f45ac99858f0286dc1c35a6cd27c3bcb9 # v1.5.1
    SHA512 1ea6295b5568d8d5d099cb1d89d19b3cae873bd869f64be4495be301561c91893f3c1c375823ce18419c780cda52aab79520293ff63ee529ded5431ec511ce5c
    HEAD_REF master
    PATCHES
        001-cpr-config.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DBUILD_CPR_TESTS=OFF
        -DUSE_SYSTEM_CURL=ON
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
