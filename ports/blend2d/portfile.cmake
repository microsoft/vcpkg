vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO blend2d/blend2d
  REF 7f292c15bafd8a7d92791f421cecb2ce84a75da8 # commited on 2023-06-16
  SHA512 dfd97a27b88bd94753b1404cbe63989186185bb6700b5c65a22b48e14fec7392038e328f30ea71a893c7bbee376f6017b4cdc2bf596259146be601d934c4fbdf
  HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BLEND2D_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  INVERTED_FEATURES
    futex      BLEND2D_NO_FUTEX
    jit        BLEND2D_NO_JIT
    logging    BLEND2D_NO_JIT_LOGGING
    tls        BLEND2D_NO_TLS
)

if(NOT BLEND2D_NO_JIT)
  vcpkg_from_github(
    OUT_SOURCE_PATH ASMJIT_SOURCE_PATH
    REPO asmjit/asmjit
    REF 3577608cab0bc509f856ebf6e41b2f9d9f71acc4 # commited on 2023-04-28
    SHA512 36557af5c82ccc8e5ef2d4effe22b75e22c2bf1f4504daae3ff813e907449be6e7b25678af071cb9dede7c6e02dc5c8ad2fc2a3da011aa660eb7f5c75ab23042
    HEAD_REF master
  )

  file(REMOVE_RECURSE "${SOURCE_PATH}/3rdparty/asmjit")

  get_filename_component(ASMJIT_SOURCE_DIR_NAME "${ASMJIT_SOURCE_PATH}" NAME)
  file(COPY "${ASMJIT_SOURCE_PATH}" DESTINATION "${SOURCE_PATH}/3rdparty")
  file(RENAME "${SOURCE_PATH}/3rdparty/${ASMJIT_SOURCE_DIR_NAME}" "${SOURCE_PATH}/3rdparty/asmjit")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBLEND2D_STATIC=${BLEND2D_STATIC}"
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(BLEND2D_STATIC)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

if(BLEND2D_STATIC)
  file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage_static.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME usage)
else()
  file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()
