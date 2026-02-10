vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO blend2d/blend2d
  REF 6dbc2cefbc996379e07104e34519a440b49b15d7 # commited on 2025-11-29
  SHA512 05c8ff3fd99b22a5a157f18cc57e393c191235a09dc4e8d0d95c7314a665ea8668da0c077c727a77a26879fcbc6ae80cc49df0b93a184cdf7bf90ec55a247c68
  HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BLEND2D_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    jit       BLEND2D_EXTERNAL_ASMJIT
  INVERTED_FEATURES
    jit        BLEND2D_NO_JIT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBLEND2D_STATIC=${BLEND2D_STATIC}"
        "-DBLEND2D_NO_FUTEX=OFF"
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/blend2d/core/api.h"
        "#if !defined(BL_STATIC)"
        "#if 0"
    )
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/blend2d/blend2d-debug.h"
        "#if defined(BL_STATIC)"
        "#if 1"
    )
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
