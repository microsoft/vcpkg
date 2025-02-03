set(DIRECTXTK_TAG oct2024)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF ${DIRECTXTK_TAG}
    SHA512 bfa254615395f464a7ec1fe544dbb3ef9cf2c755e6902ec9b472fe4e3d6848381cf476435665309c27dbacebceb2a745e865f42eb7b037364dab9fc8eb74d21f
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gameinput BUILD_GAMEINPUT
        spectre ENABLE_SPECTRE_MITIGATION
        xaudio2-9 BUILD_XAUDIO_WIN10
        xaudio2redist BUILD_XAUDIO_REDIST
)

set(EXTRA_OPTIONS "")

if(NOT VCPKG_TARGET_IS_XBOX)
  set(DXCPATH "${CURRENT_HOST_INSTALLED_DIR}/tools/directx-dxc")
  list(APPEND EXTRA_OPTIONS -DBUILD_DXIL_SHADERS=ON "-DDIRECTX_DXC_PATH=${DXCPATH}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS} ${EXTRA_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxtk12)

if("tools" IN_LIST FEATURES)

  vcpkg_download_distfile(
    MAKESPRITEFONT_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/${DIRECTXTK_TAG}/MakeSpriteFont.exe"
    FILENAME "makespritefont-${DIRECTXTK_TAG}.exe"
    SHA512 b7cc8a4b1920d85a0b826a4aac6053f0f0e7411dd115d3afc5fb5d2542661d47de11e81cc94830059ca29b0511f585913479fdba24da7f5bff03627a8117a60d
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(INSTALL "${MAKESPRITEFONT_EXE}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont-${DIRECTXTK_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont.exe")

  if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)

    vcpkg_download_distfile(
      XWBTOOL_EXE
      URLS "https://github.com/Microsoft/DirectXTK12/releases/download/${DIRECTXTK_TAG}/XWBTool.exe"
      FILENAME "xwbtool-${DIRECTXTK_TAG}.exe"
      SHA512 b08f61e7a6190f779ebecd25ec6d8c95c86ed231582b7567e83ededd5c8e0f7497f1c962535e29b204b897e0734f69d7eef78637a77bb9b401e6d1e66821e98b
    )

    file(INSTALL "${XWBTOOL_EXE}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-${DIRECTXTK_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe")

  elseif((VCPKG_TARGET_ARCHITECTURE STREQUAL arm64) OR (VCPKG_TARGET_ARCHITECTURE STREQUAL arm64ec))

    vcpkg_download_distfile(
      XWBTOOL_EXE
      URLS "https://github.com/Microsoft/DirectXTK12/releases/download/${DIRECTXTK_TAG}/XWBTool_arm64.exe"
      FILENAME "xwbtool-${DIRECTXTK_TAG}-arm64.exe"
      SHA512 b25000552c74081b0da117b4b762b98eb68c5de6f6b65a8208811900316f8138f717e6050a30dcb7c71e3e2c01cba12b8dc6d4a9ade45da39abfd2fc3ef679e3
    )

    file(INSTALL "${XWBTOOL_EXE}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-${DIRECTXTK_TAG}-arm64.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe")

  endif()

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
