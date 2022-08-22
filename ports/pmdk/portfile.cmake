vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)
set(PMDK_VERSION "1.12.0")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pmem/pmdk
    REF 73d8f958e855904dc0776a7d77d0f0d3698a65b1 #v1.12.0
    SHA512 ffe77796c9028478985ca98e4162a671e3e7f580faa46b31d0dcf8c5e97aa6478044efdf7ad238285044f18f754a20a4e2a1b5992c7b9cffa709884eb62007ab
    HEAD_REF master
)

# Build only the selected projects
vcpkg_msbuild_install(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH src/PMDK.sln
    TARGET "Solution Items\\libpmem,Solution Items\\libpmemlog,Solution Items\\libpmemblk,Solution Items\\libpmemobj,Solution Items\\libpmempool,Solution Items\\Tools\\pmempool"
    OPTIONS /p:SRCVERSION=${PMDK_VERSION}
    ADDITIONAL_LIBS getopt.lib
    INCLUDES_SUBPATH "src/include"
    INCLUDE_INSTALL_DIR "${CURRENT_PACKAGES_DIR}/include"
)

# TODO: Port needs devendoring of getopt.
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/getopt.lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/getopt.lib")

# Remove unneeded header files
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/libvmmalloc.h")
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/librpmem.h")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
