include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "Neargye/magic_enum"
    REF v0.6.1
    SHA512 546c2ea8f6aeda1b21484a3a90ec4338e15c5639b6da22350277534eeb16cfa8e987eaa1dcbb754dfaea58bd3217f95602944e2c61a694d50f9bfbaf6c5c12d6
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA 
    OPTIONS
      -DMAGIC_ENUM_OPT_BUILD_EXAMPLES=OFF
      -DMAGIC_ENUM_OPT_BUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/magic_enum)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/magic-enum RENAME copyright)
