vcpkg_fail_port_install(ON_ARCH "arm" ON_ARCH "wasm32" ON_TARGET "uwp")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO blend2d/blend2d
  REF 9e6686c0760135cc54dfd3e9e239ceac07cddb78
  SHA512 475a7fa4de4728e0c41d97e759d5c74fe5d66d28169614a9081a461fdc27e1f1c4db438d7e2a5cd9170489bbb7e352d73ec46d8bde45ff7c4a024c35fdb43e5f
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
    REF 2de7e742443e23b925b830c415268ce1470341ce
    SHA512 40ec1ec5540a20530e795c0e425322ed027d2e6e400f8f1ee1426e256ea0f3cf2e241972cdbda2f2d8e9fad06ba0ba12f0dcff9a09aa5da65cb3d01e19079966
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
