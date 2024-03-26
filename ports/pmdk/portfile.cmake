vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pmem/pmdk
    REF "${VERSION}"
    SHA512 d52319a7ff71d6cc7942b3dace16dd236b57f178cc3d0430afd67805bb73c610ada6aa6b907fdee48f6728f1bcb4e15f3f0b54ceea1eee35dbc47fc8099fc5ba
    HEAD_REF master
    PATCHES "remove_getopt.patch"
)

file(REMOVE  "${SOURCE_PATH}/src/windows/getopt" "${SOURCE_PATH}/src/test/getopt")

# Build only the selected projects
vcpkg_msbuild_install(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH src/PMDK.sln
    TARGET "Solution Items\\libpmem,Solution Items\\libpmemlog,Solution Items\\libpmemblk,Solution Items\\libpmemobj,Solution Items\\libpmempool,Solution Items\\Tools\\pmempool"
    OPTIONS /p:SRCVERSION=${VERSION}
    ADDITIONAL_LIBS getopt.lib
)

set(DEBUG_ARTIFACTS_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/x64/Debug")
set(RELEASE_ARTIFACTS_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/x64/Release")

# Install header files
file(GLOB HEADER_FILES "${SOURCE_PATH}/src/include/*.h")
file(INSTALL ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(GLOB HEADER_FILES "${SOURCE_PATH}/src/include/libpmemobj/*.h")
file(INSTALL ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/libpmemobj")

# Remove unneeded header files
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/libvmmalloc.h")
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/librpmem.h")

# Install tools (release only)
file(INSTALL "${RELEASE_ARTIFACTS_PATH}/libs/pmempool.exe" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/pmdk)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
