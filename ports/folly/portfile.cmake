if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
  message(FATAL_ERROR "Folly only supports the x64 architecture.")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)

# Required to run build/generate_escape_tables.py et al.
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON3_DIR}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/folly
    REF v2017.05.08.00
    SHA512 1f689ec288e2a5de28223bddd68fdbb37c26c46ed9d9b831cacc46580788b9bf8eed151a043a4905172e509c70ed3d845689bf2c0cd45ce05fbe76907e2049aa
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-cmakelists.patch"
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-generators.patch"
)

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(MSVC_USE_STATIC_RUNTIME ON)
else()
    set(MSVC_USE_STATIC_RUNTIME OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DMSVC_USE_STATIC_RUNTIME=${MSVC_USE_STATIC_RUNTIME}
)

# Folly runs built executables during the build, so they need access to the installed DLLs.
# TODO: Confirm it's ok that we aren't adding the debug/bin folder.
set(ENV{PATH} "$ENV{PATH};${CURRENT_INSTALLED_DIR}/bin")

vcpkg_install_cmake(MSVC_64_TOOLSET)

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/folly)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/folly/LICENSE ${CURRENT_PACKAGES_DIR}/share/folly/copyright)
