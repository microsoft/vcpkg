vcpkg_fail_port_install(ON_ARCH "arm" ON_ARCH "wasm32" ON_TARGET "uwp")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO blend2d/blend2d
  REF 069a2da836253fb531924ec07b6792022f15fd17
  SHA512 ac9a3ed10f8a24a5476c7fec97a1e0bae4f1da51c71261d7b9b780771a02208948f803ba3ca567965d9d84840da32f6fbefc0ad895b4f50938f3b446cd5153ed
  HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BLEND2D_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  INVERTED_FEATURES
    jit        BLEND2D_NO_JIT
    logging    BLEND2D_NO_JIT_LOGGING
    tls        BLEND2D_NO_TLS
)

if(NOT BLEND2D_BUILD_NO_JIT)
  vcpkg_from_github(
    OUT_SOURCE_PATH ASMJIT_SOURCE_PATH
    REPO asmjit/asmjit
    REF 0e04695f64028034b1376ecf577592992e8552fc
    SHA512 f9ae7a8862fdca9c974639196751c60b60c2e01918491040f26e288ec6a5c6f35f0da053333b044c5f35bb599a817a6650384743fefc9863b722dc8ed221555f
    HEAD_REF master
  )

  file(REMOVE_RECURSE ${SOURCE_PATH}/3rdparty/asmjit)

  get_filename_component(ASMJIT_SOURCE_DIR_NAME ${ASMJIT_SOURCE_PATH} NAME)
  file(COPY ${ASMJIT_SOURCE_PATH} DESTINATION ${SOURCE_PATH}/3rdparty)
  file(RENAME ${SOURCE_PATH}/3rdparty/${ASMJIT_SOURCE_DIR_NAME} ${SOURCE_PATH}/3rdparty/asmjit)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBLEND2D_STATIC=${BLEND2D_STATIC}
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)


if(BLEND2D_STATIC)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()


# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

if(BLEND2D_STATIC)
  # Install usage
  configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)
endif()
