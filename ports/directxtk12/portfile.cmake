set(DIRECTXTK_TAG dec2022)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF ${DIRECTXTK_TAG}
    SHA512 2ebff3d18c7d96e402ff3cb8d69f2e650030628375725785b767c9e5784e7933d1bf6264a92ef326f054b5a73c2195f49020bf9773ffd013dc32f4396bd415b6
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        spectre ENABLE_SPECTRE_MITIGATION
        xaudio2-9 BUILD_XAUDIO_WIN10
        xaudio2redist BUILD_XAUDIO_REDIST
)

set(DXCPATH ${CURRENT_HOST_INSTALLED_DIR}/tools/directx-dxc)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS} -DBUILD_TESTING=OFF -DBUILD_DXIL_SHADERS=ON -DDIRECTX_DXC_PATH=${DXCPATH}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxtk12)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(
    MAKESPRITEFONT_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/${DIRECTXTK_TAG}/MakeSpriteFont.exe"
    FILENAME "makespritefont-${DIRECTXTK_TAG}.exe"
    SHA512 6cb4351206707308382f2fe152c10dd2c99f300d960e6feac09f63e64c38225381d95f77ec557ec3dc60031227b4b878cfb18059c1bc2122e87cda1f1d25d7e2
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/${DIRECTXTK_TAG}/XWBTool.exe"
    FILENAME "xwbtool-${DIRECTXTK_TAG}.exe"
    SHA512 901b326b8c86a94c5867e26ca35fa355cadcb283bb81c1fd630385a2ed68ffb43b00ed702953781db660d184ef221184bac0cc905e8502e4d484b01c5b3ff124
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont-${DIRECTXTK_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-${DIRECTXTK_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
