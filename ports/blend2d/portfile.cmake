vcpkg_fail_port_install(ON_ARCH "arm" ON_ARCH "wasm32" ON_TARGET "uwp")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO blend2d/blend2d
  REF 960fe2fa6c93b1026a10e3db15e06db77d6817a3
  SHA512 232546d17de7f7f2f6a67ba2d88d1fca30ac6d9199216f98294e1bd0ec4e9dd33cc78a262f89da3ba1f433e9efbecded5866ddbc20f150c6a804c02687650270
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
    REF 8f25116f2bea8f5e0604dae867be817e3f12bac1
    SHA512 708ddb7bcd73e76e6485330f8935d64bbe27d526807fb877234303032247dc900751963c935d2a391fddb133eea6ae4300ade061d9202ed7f767e388e379abc8
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
