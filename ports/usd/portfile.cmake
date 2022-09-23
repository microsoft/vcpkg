# Don't file if the bin folder exists. We need exe and custom files.
SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PixarAnimationStudios/USD
    REF 3abc46452b1271df7650e9948fef9f0ce602e3b2 # v22.08
    SHA512 bfb73daafd630c770ae7ca273077d63ed9a6561f61366bdf31b2c610cd269659ddd880049f1183d2f9fa8dc2ecfbe26cc44efe760b6560656b9280dd76ecb0d5
    HEAD_REF release
    PATCHES
        fix_build-location.patch
)

vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY)
vcpkg_add_to_path("${PYTHON2_DIR}")

IF (VCPKG_TARGET_IS_WINDOWS)
ELSE()
file(REMOVE "${SOURCE_PATH}/cmake/modules/FindTBB.cmake")
ENDIF()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPXR_BUILD_ALEMBIC_PLUGIN:BOOL=OFF
        -DPXR_BUILD_EMBREE_PLUGIN:BOOL=OFF
        -DPXR_BUILD_IMAGING:BOOL=OFF
        -DPXR_BUILD_MONOLITHIC:BOOL=OFF
        -DPXR_BUILD_TESTS:BOOL=OFF
        -DPXR_BUILD_USD_IMAGING:BOOL=OFF
        -DPXR_ENABLE_PYTHON_SUPPORT:BOOL=OFF
        -DPXR_BUILD_EXAMPLES:BOOL=OFF
        -DPXR_BUILD_TUTORIALS:BOOL=OFF
        -DPXR_BUILD_USD_TOOLS:BOOL=OFF
)

vcpkg_cmake_install()

file(
    RENAME
        "${CURRENT_PACKAGES_DIR}/pxrConfig.cmake"
        "${CURRENT_PACKAGES_DIR}/cmake/pxrConfig.cmake")

vcpkg_cmake_config_fixup(PACKAGE_NAME pxr CONFIG_PATH cmake)

# Remove duplicates in debug folder
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/plugin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/pxrConfig.cmake")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# # Move all dlls to bin
file(GLOB RELEASE_DLL "${CURRENT_PACKAGES_DIR}/lib/*.dll")
file(GLOB RELEASE_PDB "${CURRENT_PACKAGES_DIR}/lib/*.pdb")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")

file(GLOB DEBUG_DLL "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
file(GLOB DEBUG_PDB "${CURRENT_PACKAGES_DIR}/debug/lib/*.pdb")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")

foreach(CURRENT_FROM ${RELEASE_DLL} ${DEBUG_DLL} ${RELEASE_PDB} ${DEBUG_PDB})
    string(REPLACE "/lib/" "/bin/" CURRENT_TO ${CURRENT_FROM})
    file(RENAME ${CURRENT_FROM} ${CURRENT_TO})
endforeach()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/pxr/pxrConfig.cmake" "/cmake/pxrTargets.cmake" "/pxrTargets.cmake")
