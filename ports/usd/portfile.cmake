vcpkg_fail_port_install(ON_ARCH "x86")

# Don't file if the bin folder exists. We need exe and custom files.
SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PixarAnimationStudios/USD
    REF be1a80f8cb91133ac75e1fc2a2e1832cd10d91c8 # v20.02
    SHA512 12c7cf7e5320b168ddde870b1a68b482515b33bd29206c4f6cbb248b9071b866c47353bf496890e01950abb5f725157eca576f9dc403e15020474f9a653b43fe
    HEAD_REF master
    PATCHES
        fix-build-error.patch
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
