vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO blend2d/blend2d
  REF 69a91aa69e6025d9b0954b23b03bdb864c68b447 # commited on 2024-06-28
  SHA512 153f2ac21a8c030fc63b4c3b448dd2fb4e32cddaddb4226a0b2b81c1201438d9e41ecbf08f89c68d53626cc626c9dc556db44721d2dd179778ac688c00157d05
  HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BLEND2D_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  INVERTED_FEATURES
    jit        BLEND2D_NO_JIT
    logging    BLEND2D_NO_JIT_LOGGING
    tls        BLEND2D_NO_TLS
)

if(NOT BLEND2D_NO_JIT)
  vcpkg_from_github(
    OUT_SOURCE_PATH ASMJIT_SOURCE_PATH
    REPO asmjit/asmjit
    REF ffac9f36fb045dd2c6a81e1b5b9ccc115e5ef924 # commited on 2024-06-28
    SHA512 3a594bdea7095f66356f8c21e03a4db2535811988726c25a29e66721cb703dc9dceddeb5f8a6c7daeafba3fbf6dd07e71375446d8dfb182f57c14bce28192774
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
        "-DBLEND2D_NO_FUTEX=OFF"
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
