set(DIRECTXTK_TAG oct2025)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF ${DIRECTXTK_TAG}
    SHA512 8ecb03c2773f68b42959940004b483c5978a4e933ddd24ef0db9ecec721daf691927b64d1d4c00430df5569bf0358874fc565bf4225c336b4846f353fef5088c
    HEAD_REF main
    PATCHES CMake-build-options-improvements.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gameinput BUILD_GAMEINPUT
        xinput BUILD_XINPUT
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
    SHA512 edec18a1c7790d6f27f8d910307a38a037784cc974b38debb8ef6eb77369941b60bf7cb52de4150f80bca4ab541d76d54f21ef91524b83b11b684f0a92e1c879
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(INSTALL "${MAKESPRITEFONT_EXE}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont-${DIRECTXTK_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont.exe")

  if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)

    vcpkg_download_distfile(
      XWBTOOL_EXE
      URLS "https://github.com/Microsoft/DirectXTK12/releases/download/${DIRECTXTK_TAG}/XWBTool.exe"
      FILENAME "xwbtool-${DIRECTXTK_TAG}.exe"
      SHA512 68ff3f4a99585e08698c6385550628341e31218315029700c9b8d9a17118ba964856358bc2bebc951b6ec8d1584e8d62138505780897430509dca2652832384b
    )

    file(INSTALL "${XWBTOOL_EXE}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-${DIRECTXTK_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe")

  elseif((VCPKG_TARGET_ARCHITECTURE STREQUAL arm64) OR (VCPKG_TARGET_ARCHITECTURE STREQUAL arm64ec))

    vcpkg_download_distfile(
      XWBTOOL_EXE
      URLS "https://github.com/Microsoft/DirectXTK12/releases/download/${DIRECTXTK_TAG}/XWBTool_arm64.exe"
      FILENAME "xwbtool-${DIRECTXTK_TAG}-arm64.exe"
      SHA512 8e9d0fdd206bff4e3c0b344ed754a16cee913833be205c822d41ed3264d3578ae168ef415043ff8f95b38890c37457a56ee7677b26d95b8afd60dd307bffb9e0
    )

    file(INSTALL "${XWBTOOL_EXE}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-${DIRECTXTK_TAG}-arm64.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe")

  endif()

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
