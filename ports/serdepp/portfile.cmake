vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO injae/serdepp
    REF v0.1.4-pre.1
    SHA512 a09f6d37a32b953aee0cff2977024f3aa501d634e283f8d9c73378306e8db32bf2529db79d3a138b164deda95f35a95b497bc979fd755b96b537a613330b889d
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DENABLE_INLINE_CPPM_TOOLS=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/serdepp)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/cmake
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/lib/cmake
)

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/serdepp RENAME copyright)
