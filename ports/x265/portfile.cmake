include(vcpkg_common_functions)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO multicoreware/x265
    REF 3.2
    SHA512 e98e26a9d3c2eb7f147ba052d9d8009e1c47e54905375b29e813f33ffddf8b7fac55ea455ae6d28ed1ade2d90f887c7cafe374873cd48b6c5e2560ddd21ccb84
    HEAD_REF master
    PATCHES
        disable-install-pdb.patch
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
