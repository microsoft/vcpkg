set(DIRECTXTK_TAG feb2024)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF ${DIRECTXTK_TAG}
    SHA512 de8ab193569291f1125cb594f458d9d4b921af229896cef3f3d9ec5f33fa0df8ac369dfb84f6761b8833de010feaa524417838d638b379666d2f0c55e50d23c8
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
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
    SHA512 bdb6f547bbb42a17d491e96cc4368fe5311647d570b84eb4297e937d81f8d6e6cc7bde1fa784dc9140bf2f1205e483835104295d0ef9c59240d86721422bb0c9
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(INSTALL "${MAKESPRITEFONT_EXE}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont-${DIRECTXTK_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont.exe")

  if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)

    vcpkg_download_distfile(
      XWBTOOL_EXE
      URLS "https://github.com/Microsoft/DirectXTK12/releases/download/${DIRECTXTK_TAG}/XWBTool.exe"
      FILENAME "xwbtool-${DIRECTXTK_TAG}.exe"
      SHA512 96ca2c1ebdbd33eb87843672d668bf42ac09312065ae8192a28ae3885ae711314905a9d2be787994e7fdfef86cdbe144f1ab23126c164de7b31385b7ec487650
    )

    file(INSTALL "${XWBTOOL_EXE}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-${DIRECTXTK_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe")

  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL arm64)

    vcpkg_download_distfile(
      XWBTOOL_EXE
      URLS "https://github.com/Microsoft/DirectXTK12/releases/download/${DIRECTXTK_TAG}/XWBTool_arm64.exe"
      FILENAME "xwbtool-${DIRECTXTK_TAG}-arm64.exe"
      SHA512 4344d77812fdad79e3f94b9e4b457dc5ece8eb6386250b76caf16a393bc329a05134fbceb58107ea43fca7426c0ca4e04bb23512ff418546ac1c7165d190bbbf
    )

    file(INSTALL "${XWBTOOL_EXE}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-${DIRECTXTK_TAG}-arm64.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe")

  endif()

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
