include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR "${VCPKG_TARGET_ARCHITECTURE} is currently not supported; only x64 is available.")
endif()
if(VCPKG_CMAKE_SYSTEM_NAME)
    message(FATAL_ERROR "This port currently can only be built for Windows Desktop")
endif()

# Download source
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pmem/pmdk
    REF 1.6
    SHA512 f66e4edf1937d51abfa7c087b65a64109cd3d2a8d9587d6c4fc28a1003d67ec1f35a0011c9a9d0bfe76ad7227be83e86582f8405c988eac828d8ae5d0a399483
    HEAD_REF master
    PATCHES
        addPowerShellExecutionPolicy.patch
        v141.patch
)

get_filename_component(PMDK_VERSION "${SOURCE_PATH}" NAME)
string(REPLACE "pmdk-" "" PMDK_VERSION "${PMDK_VERSION}")

# Build only the selected projects
vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH src/PMDK.sln
    INCLUDES_SUBPATH src/include
    TARGET "Solution Items\\libpmem,Solution Items\\libpmemlog,Solution Items\\libpmemblk,Solution Items\\libpmemobj,Solution Items\\libpmempool,Solution Items\\libvmem,Solution Items\\Tools\\pmempool"
    OPTIONS /p:SRCVERSION=${PMDK_VERSION}
    ALLOW_ROOT_INCLUDES
)

# Remove unneeded files
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/include/libvmmalloc.h
    ${CURRENT_PACKAGES_DIR}/include/librpmem.h
    ${CURRENT_PACKAGES_DIR}/include/.cstyleignore
    ${CURRENT_PACKAGES_DIR}/include/README
    ${CURRENT_PACKAGES_DIR}/include/libpmemobj++
    ${CURRENT_PACKAGES_DIR}/lib/getopt.lib
    ${CURRENT_PACKAGES_DIR}/lib/jemalloc.lib
    ${CURRENT_PACKAGES_DIR}/lib/libpmemcommon.lib
    ${CURRENT_PACKAGES_DIR}/debug/lib/getopt.lib
    ${CURRENT_PACKAGES_DIR}/debug/lib/jemalloc.lib
    ${CURRENT_PACKAGES_DIR}/debug/lib/libpmemcommon.lib
)

vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pmdk)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pmdk/LICENSE ${CURRENT_PACKAGES_DIR}/share/pmdk/copyright)
