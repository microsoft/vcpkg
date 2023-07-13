set(DIRECTXTEX_TAG jun2023)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF ${DIRECTXTEX_TAG}
    SHA512 7b09903b8fbb15f6e13a50608b80ff1128703f7843517db99dd1c05e01a0ab27ed4ac29f29a59de1f384787fbb75fb4f359bbddcd25483cb323fcc3750f0833d
    HEAD_REF main
    )

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dx11 BUILD_DX11
        dx12 BUILD_DX12
        openexr ENABLE_OPENEXR_SUPPORT
        spectre ENABLE_SPECTRE_MITIGATION
        tools BUILD_TOOLS
)

if(VCPKG_TARGET_IS_MINGW AND ("dx11" IN_LIST FEATURES))
    message(NOTICE "Building ${PORT} for MinGW requires the HLSL Compiler fxc.exe also be in the PATH. See https://aka.ms/windowssdk.")
endif()

if (VCPKG_HOST_IS_LINUX)
    message(WARNING "Build ${PORT} requires GCC version 9 or later")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS} -DBUILD_SAMPLE=OFF -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxtex)

if("tools" IN_LIST FEATURES)

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  if((VCPKG_TARGET_ARCHITECTURE STREQUAL x64) AND (NOT ("openexr" IN_LIST FEATURES)))

    vcpkg_download_distfile(
      TEXASSEMBLE_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texassemble.exe"
      FILENAME "texassemble-${DIRECTXTEX_TAG}.exe"
      SHA512 e013d099b121147137db006d6ebefd90a374777160fcedf09e038eaab6c842aaaf0db7241dca3c56d35a91d4ea9f19fd56a007ac1bc05d12216c079974ec138e
    )

    vcpkg_download_distfile(
      TEXCONV_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texconv.exe"
      FILENAME "texconv-${DIRECTXTEX_TAG}.exe"
      SHA512 e5ea3a36dc1cc60e1426cec7af0e96f21ddf8e8ed8b2b666a5003db59008558f07f44e962508c28c8e5d2f14c92350a05da9688c40e1d5a41c7851a0c474470f
    )

    vcpkg_download_distfile(
      TEXDIAG_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texdiag.exe"
      FILENAME "texdiag-${DIRECTXTEX_TAG}.exe"
      SHA512 98c4cdb118ed6ef67d0e0a6a8f3e961e7702f1dac2b36f4ba2bc19191989fc72c847d3f65c4acbb63c8bb5adc167055a0adc90e3fce3b65629d01a956427d60e
    )

    file(INSTALL
      "${TEXASSEMBLE_EXE}"
      "${TEXCONV_EXE}"
      "${TEXDIAG_EXE}"
      DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble-${DIRECTXTEX_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble.exe")
    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv-${DIRECTXTEX_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv.exe")
    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texdiag-${DIRECTXTEX_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texadiag.exe")

  elseif((VCPKG_TARGET_ARCHITECTURE STREQUAL arm64) AND (NOT ("openexr" IN_LIST FEATURES)))

    vcpkg_download_distfile(
      TEXASSEMBLE_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texassemble_arm64.exe"
      FILENAME "texassemble-${DIRECTXTEX_TAG}-arm64.exe"
      SHA512 7890b3cf3c6d8834c3c6752d2ba82d34d91935f684f7c8b96a3840f4b1662fe2538a30a0a3f88fa3989728c1d4b7b29ca03274f77eaa1b1fa3acf6e5e98aa4f4
    )

    vcpkg_download_distfile(
      TEXCONV_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texconv_arm64.exe"
      FILENAME "texconv-${DIRECTXTEX_TAG}-arm64.exe"
      SHA512 160cf3fe6d4488fc47e30aba763d8513f224b68e7a4b85360149752b32d52050714bc6f10a7ea7b8ccd1e8a564efccec73a968a5e9551a2f2cedfb6b764fbe9b
    )

    vcpkg_download_distfile(
      TEXDIAG_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texdiag_arm64.exe"
      FILENAME "texdiag-${DIRECTXTEX_TAG}-arm64.exe"
      SHA512 d70ed9a12a83a2a28a9a8682d25d0c7f569509c422cc8cf0fe66789d62d86d305f7da3275ab3bf969e20bedd6f265c6520400649d8f917cf3106a48dc80e789a
    )

    file(INSTALL
      "${TEXASSEMBLE_EXE}"
      "${TEXCONV_EXE}"
      "${TEXDIAG_EXE}"
      DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble-${DIRECTXTEX_TAG}-arm64.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble.exe")
    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv-${DIRECTXTEX_TAG}-arm64.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv.exe")
    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texdiag-${DIRECTXTEX_TAG}-arm64.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texadiag.exe")

  elseif("dx11" IN_LIST FEATURES)

    vcpkg_copy_tools(
          TOOL_NAMES texassemble texconv texdiag
          SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake"
      )

  endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
