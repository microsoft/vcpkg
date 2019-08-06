include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/sol2
    REF 57990845726e17fba11a39cfcb1fc0127a7ea638
    SHA512 3894610a08f7a47c43fc14e2abe750fc41ce7ea90106a6f0290d1ae2bbcc829d340f2c211426686c061a42a77effec1f1c898f19153e9f904e5fab416c7b6399
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
