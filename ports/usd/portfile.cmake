# Don't file if the bin folder exists. We need exe and custom files.
SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PixarAnimationStudios/USD
    REF v19.05
    SHA512 4d708835f6efd539d5fff5cbaf0ec4d68c6d0c4d813ee531c4b9589ee585b720c34e993ef0a7ad0104a921ebd7ab8dec46d0c9284ec7f11993057fe81d3729e0
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY)
vcpkg_add_to_path("${PYTHON2_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPXR_BUILD_ALEMBIC_PLUGIN:BOOL=OFF
        -DPXR_BUILD_EMBREE_PLUGIN:BOOL=OFF
        -DPXR_BUILD_IMAGING:BOOL=OFF
        -DPXR_BUILD_MAYA_PLUGIN:BOOL=OFF
        -DPXR_BUILD_MONOLITHIC:BOOL=OFF
        -DPXR_BUILD_TESTS:BOOL=OFF
        -DPXR_BUILD_USD_IMAGING:BOOL=OFF
        -DPXR_ENABLE_PYTHON_SUPPORT:BOOL=OFF
)

vcpkg_install_cmake()

file(
    RENAME
        "${CURRENT_PACKAGES_DIR}/pxrConfig.cmake"
        "${CURRENT_PACKAGES_DIR}/cmake/pxrConfig.cmake")

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

vcpkg_copy_pdbs()

# Remove duplicates in debug folder
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(
    COPY ${SOURCE_PATH}/LICENSE.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/usd/copyright)

# Move all dlls to bin
file(GLOB RELEASE_DLL ${CURRENT_PACKAGES_DIR}/lib/*.dll)
file(GLOB DEBUG_DLL ${CURRENT_PACKAGES_DIR}/debug/lib/*.dll)
foreach(CURRENT_FROM ${RELEASE_DLL} ${DEBUG_DLL})
    string(REPLACE "/lib/" "/bin/" CURRENT_TO ${CURRENT_FROM})
    file(RENAME ${CURRENT_FROM} ${CURRENT_TO})
endforeach()
