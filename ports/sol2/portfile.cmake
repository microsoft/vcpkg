include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/sol2
    REF 230928c0451544dbc97b2e0a007ca16c3566df66
    SHA512 46e8fcb65abd05db5e8f0db45cb2d3ebece9e40a2cc95490d3aa0cc539b29d38267b23818b7361b009fb31fa7ab9b0c933368e65f231ff63be7a1381b1e635b6
    HEAD_REF develop
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sol2)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sol2 RENAME copyright)
