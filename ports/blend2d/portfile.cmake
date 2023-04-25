vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO blend2d/blend2d
  REF 7b420376ed32f3979f860d8c3be04128ab5c6690
  SHA512 88818bfe18b0638b02f84277a4584ddf2cee2158540c1794c3a96c12891274472dc896bef94408baf9ec398e30549c0b3feda58e4b7bf3014a0cf436f394a3ed
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
    REF 51b10b19b6631434d3f9ad536a6fb140944a36d2 # commited on 2023-03-25
    SHA512 1fba5159d2adad64e9a2b07a1f90de6988d1da47b9802ca8b57c61a89d8a90924525f6d0d6607279994bdbadcf693b2cc96cd7e4bf7f018ad64127b640dc38fb
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
