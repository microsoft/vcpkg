include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/sol2
    REF v2.20.3
    SHA512 f1d39a6762c7c9c40bffd08129a80c4c8dd70ffcaadc195cbcd681471e6978176d0ae06d4b8db6aabc05b0ae2670c10bd287b9e859ec7810f2441c3c6c8fe521
    HEAD_REF develop
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/sol2_fix_targets.patch
        ${CMAKE_CURRENT_LIST_DIR}/sol2_fix_install_interface.patch
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
