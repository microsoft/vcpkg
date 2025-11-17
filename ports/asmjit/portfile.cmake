vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO asmjit/asmjit
    REF 28295814dd126459711de4bc20b5d1502b000d4e # commited on 2025-11-15
    SHA512 1145a8d74e790c17a22b65a1a650cd15bd071302f04e31dee2426d9db681b8684984a63233f7902069620889fa6311275e824a8d7f8336a7c4213b39957d4198
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
