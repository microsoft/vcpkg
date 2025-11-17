vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO asmjit/asmjit
    REF 2ff454d41555d16d0759e4d0e95ade3c875b615e # commited on 2025-06-15
    SHA512 b27413e6e2cf566050a02d3469bdeed3c72380c72a8c011275d4d2412b42e03722545c878a0a94f3e5e27a2e6d517c53129c98ab765fc3e195bc02077e21c052
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ASMJIT_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DASMJIT_STATIC=${ASMJIT_STATIC}
 )

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/asmjit)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/asmjit/core/api-config.h"
        "#if !defined(ASMJIT_STATIC)"
        "#if 0"
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
