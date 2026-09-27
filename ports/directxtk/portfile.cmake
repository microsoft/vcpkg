set(DIRECTXTK_TAG may2026)

if(VCPKG_TARGET_IS_MINGW)
    message(NOTICE "Building ${PORT} for MinGW requires the HLSL Compiler fxc.exe also be in the PATH. See https://aka.ms/windowssdk.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF ${DIRECTXTK_TAG}
    SHA512 9306774b06f52b4c37938fe4b3a10df8c7a85652188a25dc25e60ae9ff6fbf9d2cf920b114de3fc3945c564054cbb166cc45fca073021129e75ce282a51636e7
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gameinput BUILD_GAMEINPUT
        windows-gaming-input BUILD_WGI
        spectre ENABLE_SPECTRE_MITIGATION
        tools BUILD_TOOLS
        xaudio2-9 BUILD_XAUDIO_WIN10
        xaudio2-8 BUILD_XAUDIO_WIN8
        xaudio2redist BUILD_XAUDIO_REDIST
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxtk)

if("tools" IN_LIST FEATURES)

  vcpkg_download_distfile(
    MAKESPRITEFONT_EXE
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/${DIRECTXTK_TAG}/MakeSpriteFont.exe"
    FILENAME "makespritefont-${DIRECTXTK_TAG}.exe"
    SHA512 1b3f6e2b9394316bfb0ef828850368be9b3ca6227501c28e09a108763f63e2a010588222ee6a3f64233ca8deae663098ca407e41c2a0c93a745078dc24053f5f
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

  file(INSTALL "${MAKESPRITEFONT_EXE}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont-${DIRECTXTK_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont.exe")

  if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)

    vcpkg_download_distfile(
      XWBTOOL_EXE
      URLS "https://github.com/Microsoft/DirectXTK/releases/download/${DIRECTXTK_TAG}/XWBTool.exe"
      FILENAME "xwbtool-${DIRECTXTK_TAG}.exe"
      SHA512 1b79d2f2d46a656810e8ef9e2061c9f0071f8304187a144e2aebbfdba2da3d9133a91114e22dcfc178f0bcf8fdb421640252800caea993c27bf987f2e50abafa
    )

    file(INSTALL "${XWBTOOL_EXE}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool-${DIRECTXTK_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool.exe")

  elseif((VCPKG_TARGET_ARCHITECTURE STREQUAL arm64) OR (VCPKG_TARGET_ARCHITECTURE STREQUAL arm64ec))

    vcpkg_download_distfile(
      XWBTOOL_EXE
      URLS "https://github.com/Microsoft/DirectXTK/releases/download/${DIRECTXTK_TAG}/XWBTool_arm64.exe"
      FILENAME "xwbtool-${DIRECTXTK_TAG}-arm64.exe"
      SHA512 dabffcb328f440eb699fcc80f3e33bb093e2f067fa6114bf0a5c521eaa5ab935ac568195a2e25eccb5c228b0ab1b1979121d6936eadae7f3dec8a2aed648a9b4
    )

    file(INSTALL "${XWBTOOL_EXE}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool-${DIRECTXTK_TAG}-arm64.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool.exe")

  else()

    vcpkg_copy_tools(
          TOOL_NAMES XWBTool
          SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin"
      )

  endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
