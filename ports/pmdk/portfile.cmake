vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_fail_port_install(ON_ARCH "arm" "x86")

set(PMDK_VERSION "1.9")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pmem/pmdk
    REF 1926ffb8f3f5f0617b3b3ed32029d437c272f187 #Commit id corresponding to the version 1.9
    SHA512 dc828866291f1c4a6901de5845d21a60eb2c7951c6b5ebc680b309a4e5f7596b0d9bea663f997dff9f08f666124850aecd2219caf12bab571b4c2b63db28ec7f
    HEAD_REF master
    PATCHES
        remove-non-ascii-character.patch
)

# Build only the selected projects
vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/src/PMDK.sln
    TARGET "Solution Items\\libpmem,Solution Items\\libpmemlog,Solution Items\\libpmemblk,Solution Items\\libpmemobj,Solution Items\\libpmempool,Solution Items\\Tools\\pmempool"
    OPTIONS /p:SRCVERSION=${PMDK_VERSION}
)

set(DEBUG_ARTIFACTS_PATH ${SOURCE_PATH}/src/x64/Debug)
set(RELEASE_ARTIFACTS_PATH ${SOURCE_PATH}/src/x64/Release)

# Install header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/src/include/*.h)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(GLOB HEADER_FILES ${SOURCE_PATH}/src/include/libpmemobj/*.h)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/libpmemobj)

# Remove unneeded header files
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/libvmmalloc.h)
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/librpmem.h)

# Install libraries (debug)
file(GLOB LIB_DEBUG_FILES ${DEBUG_ARTIFACTS_PATH}/libs/libpmem*.lib)
file(INSTALL ${LIB_DEBUG_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/libpmemcommon.lib)
file(GLOB LIB_DEBUG_FILES ${DEBUG_ARTIFACTS_PATH}/libs/libpmem*.dll)
file(INSTALL ${LIB_DEBUG_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

# Install libraries (release)
file(GLOB LIB_RELEASE_FILES ${RELEASE_ARTIFACTS_PATH}/libs/libpmem*.lib)
file(INSTALL ${LIB_RELEASE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libpmemcommon.lib)
file(GLOB LIB_RELEASE_FILES ${RELEASE_ARTIFACTS_PATH}/libs/libpmem*.dll)
file(INSTALL ${LIB_RELEASE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

# Install tools (release only)
file(INSTALL ${RELEASE_ARTIFACTS_PATH}/libs/pmempool.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/pmdk)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
