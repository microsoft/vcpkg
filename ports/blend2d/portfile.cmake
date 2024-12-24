vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO blend2d/blend2d
  REF 9a86b2700917ced827c008c3dd488108afb3490c # commited on 2024-07-08
  SHA512 741404d4c7044e8d338ad5b02e6b6e00b7e40f9c9cf03c53de4607447b552f559747d4a96d53c7b6311abb6348f4bf8a4abd6d726c51be8c1b7e65e540c4f128
  HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BLEND2D_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  INVERTED_FEATURES
    jit        BLEND2D_NO_JIT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBLEND2D_STATIC=${BLEND2D_STATIC}"
        "-DBLEND2D_NO_FUTEX=OFF"
        "-DBLEND2D_EXTERNAL_ASMJIT=ON"
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/blend2d/api.h"
        "#if !defined(BL_STATIC)"
        "#if 0"
    )
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/blend2d-debug.h"
        "#if defined(BL_STATIC)"
        "#if 1"
    )
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
