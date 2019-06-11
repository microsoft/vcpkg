include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/sol2
    REF 5a4d7dca7f77e65aed15c0fb8f8acf1570677335
    SHA512 5fc88a000d7a8379c3c8d8ee2dc3371514c4a58dcc3340b700565278ec69b7be0f108d599e3fe3b3ca347ef7c5b25ac01d83b1a988ac0189c8517b6ae66e96d6
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
