set(DIRECTXTK_TAG feb2023)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF feb2023b
    SHA512 e17b726e8f73bd499ab0c7e9c1d8fb7f1af3bad3220a8b3accbf5993b735bcd7caa349b767d09af74a800e0cf1852749280fc0e7a0cf8fe186dbf13dd07ba11d
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        spectre ENABLE_SPECTRE_MITIGATION
        xaudio2-9 BUILD_XAUDIO_WIN10
        xaudio2redist BUILD_XAUDIO_REDIST
)

set(EXTRA_OPTIONS -DBUILD_TESTING=OFF)

if(NOT VCPKG_TARGET_IS_XBOX)
  set(DXCPATH "${CURRENT_HOST_INSTALLED_DIR}/tools/directx-dxc")
  list(APPEND EXTRA_OPTIONS -DBUILD_DXIL_SHADERS=ON "-DDIRECTX_DXC_PATH=${DXCPATH}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS} ${EXTRA_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxtk12)

if(VCPKG_HOST_IS_WINDOWS AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(
    MAKESPRITEFONT_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/${DIRECTXTK_TAG}/MakeSpriteFont.exe"
    FILENAME "makespritefont-${DIRECTXTK_TAG}.exe"
    SHA512 2cf274cd1c9a4692b84bd3ac9c3266eb3a20b1598b29f8f77893cb5911c3e70c4b0151df54a3fdef93215db22c76854a61b6d3688ac9cd1875611fe34d196da3
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/${DIRECTXTK_TAG}/XWBTool.exe"
    FILENAME "xwbtool-${DIRECTXTK_TAG}.exe"
    SHA512 ab328e336228ec5e1abe0aa44707203325d743432728a1d8d01990529350fe6dc0f1bc5d58ce961456f6273922169abc1a4a9ca3804dd7f40198a182462c332d
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
