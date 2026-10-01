vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gocha/sf2cute
    REF 3c5fc83b6ba3d1feb377f9c86021fd77499eb7c0
    HEAD_REF master
    SHA512 54db9c9e5703b3efb156d5fa8ffd2f90b966318002c12aa1ddfcea9c5b4119caf1e47d823ac971b0f94ab4dc76daa1e9d5f24a8ac94fa7c2bfebb592a2a1afe1
)

set(BUILD_EXAMPLE OFF)

if("example" IN_LIST FEATURES)
    set(BUILD_EXAMPLE ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DSF2CUTE_EXAMPLES_INSTALL_DIR=tools/sf2cute
    OPTIONS_RELEASE
        -DSF2CUTE_INSTALL_EXAMPLES=${BUILD_EXAMPLE}
        "-DSF2CUTE_EXAMPLES_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/tools/sf2cute"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/sf2cute" RENAME copyright)

if(BUILD_EXAMPLE)
  vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/sf2cute")
endif()
