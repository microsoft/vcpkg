include(vcpkg_common_functions)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO multicoreware/x265
    REF 3.0
    SHA512 698fd31bf30c65896717225de69714523bcbd3d835474f777bf32c3a6d6dbbf941a09db076e13e76917a5ca014c89fca924fcb0ea3d15bc09748b6fc834a4ba2
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/disable-install-pdb.patch
)

set(ENABLE_ASSEMBLY OFF)
if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
    set(ENV{PATH} "$ENV{PATH};${NASM_EXE_PATH}")
    set(ENABLE_ASSEMBLY ON)
endif ()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/source
    PREFER_NINJA
    OPTIONS
        -DENABLE_ASSEMBLY=${ENABLE_ASSEMBLY}
        -DENABLE_SHARED=${ENABLE_SHARED}
    OPTIONS_DEBUG
        -DENABLE_CLI=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# remove duplicated include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/x265)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/x265 ${CURRENT_PACKAGES_DIR}/tools/x265/x265)
elseif(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/x265.exe ${CURRENT_PACKAGES_DIR}/tools/x265/x265.exe)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
endif()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/x265)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/x265)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/x265/COPYING ${CURRENT_PACKAGES_DIR}/share/x265/copyright)
