vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO blend2d/blend2d
  REF 92ba4eaa2f22331bc9823ddb47f53dd8ce683c8b
  SHA512 bb5585d0b73c2acc815a96d613c53c334b5f0d398e99cbaa7b7cf0c63b7a17d36a9f505779d9f5b549b6c6de69414183aadf1b2b8117552bdb273ad7167d761e
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
    REF e7a728018e5d88ffa477430fa63bdebbf480fb02
    SHA512 99e0f40d6d90ff194cb9e3238c5090a7fb09f871eeaad24283c461214ef584002d4b00c066b303698f71c55b2ccdb926704ec485956d35fc70ea829eff4888a7
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

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

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
