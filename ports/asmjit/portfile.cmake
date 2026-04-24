vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO asmjit/asmjit
    REF c87860217e43e2a06060fcaae5b468f6a55b9963 # commited on 2025-12-13
    SHA512 189aa9261d3a050e19d2d7d5bddea33330745b167d1e70640d58715bc5266bb9bf10be591ba15f8dd9affee7a6ff636022b32ae89597ff427c87c0b563997664
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
