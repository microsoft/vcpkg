set(DIRECTXTEX_TAG jun2024)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF ${DIRECTXTEX_TAG}
    SHA512 5ad160d4279c4b74c5ad29c7d830972ad8b9f8b42c3c0d3d889cc6c98f97c9285cd4c753ffcb88ed23cb40786071ea50917fd273b653f55f497e6ea10181c560
    HEAD_REF main
    )

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dx11 BUILD_DX11
        dx12 BUILD_DX12
        jpeg ENABLE_LIBJPEG_SUPPORT
        openexr ENABLE_OPENEXR_SUPPORT
        png ENABLE_LIBPNG_SUPPORT
        spectre ENABLE_SPECTRE_MITIGATION
        tools BUILD_TOOLS
)

set(EXTRA_OPTIONS -DBUILD_SAMPLE=OFF)

if(VCPKG_TARGET_IS_WINDOWS AND NOT (VCPKG_TARGET_IS_XBOX OR VCPKG_TARGET_IS_MINGW) AND NOT "dx12" IN_LIST FEATURES)
  list(APPEND EXTRA_OPTIONS "-DCMAKE_DISABLE_FIND_PACKAGE_directx-headers=TRUE")
endif()

if(VCPKG_TARGET_IS_MINGW AND ("dx11" IN_LIST FEATURES))
  message(NOTICE "Building ${PORT} for MinGW requires the HLSL Compiler fxc.exe also be in the PATH. See https://aka.ms/windowssdk.")
endif()

if("xbox" IN_LIST FEATURES)
  if((NOT (DEFINED DIRECTXTEX_XBOX_CONSOLE_TARGET)) OR (DIRECTXTEX_XBOX_CONSOLE_TARGET STREQUAL "scarlett"))
    list(APPEND FEATURE_OPTIONS "-DBUILD_XBOX_EXTS_SCARLETT=ON")
    message(NOTICE "Building ${PORT} with Xbox Series X|S extensions")
  elseif(DIRECTXTEX_XBOX_CONSOLE_TARGET STREQUAL "xboxone")
    list(APPEND FEATURE_OPTIONS "-DBUILD_XBOX_EXTS_XBOXONE=ON")
    message(NOTICE "Building ${PORT} with Xbox One extensions")
  else()
    message(FATAL_ERROR "The triplet variable DIRECTXTEX_XBOX_CONSOLE_TARGET should be set to 'xboxone' or 'scarlett'.")
  endif()
endif()

if (VCPKG_HOST_IS_LINUX)
    message(WARNING "Build ${PORT} requires GCC version 9 or later")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS} ${EXTRA_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxtex)

if("tools" IN_LIST FEATURES)

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  if((VCPKG_TARGET_ARCHITECTURE STREQUAL x64) AND (NOT (("openexr" IN_LIST FEATURES) OR ("xbox" IN_LIST FEATURES))))

    vcpkg_download_distfile(
      TEXASSEMBLE_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texassemble.exe"
      FILENAME "texassemble-${DIRECTXTEX_TAG}.exe"
      SHA512 1226bbb29ebe750d4371bf07dfab3511a22c371964cc4b977917466af5619517a6d4ac02a5da2d69676524d17a5c1efabc11328db41515cd7ae911efcb919397
    )

    vcpkg_download_distfile(
      TEXCONV_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texconv.exe"
      FILENAME "texconv-${DIRECTXTEX_TAG}.exe"
      SHA512 e28e29af20f3703bf88dc43f9dbbad4844c8746a8b22aa74dbe7f0ea8668b263a7798ab99373c61b7ed89efbc31946b0d75dde6acadcc649ad8fde4d78887c2f
    )

    vcpkg_download_distfile(
      TEXDIAG_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texdiag.exe"
      FILENAME "texdiag-${DIRECTXTEX_TAG}.exe"
      SHA512 b535c9a9f36e35821a300f32dc193493e8e27a262e221d60719bf47e5da8927da50faad6a37995f520c4411af083ed36c2248c60be28e9bd8bdb482f71e8fb50
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
      SHA512 18a9022d550a8c9d0a74f1a86749c3c2766f71c23ad93efeab2240f35bfe5dcce575d0f13a1e5bfc4fe1a2abd2903c1b71dc0dcab9c30821710e4f3a2595d674
    )

    vcpkg_download_distfile(
      TEXCONV_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texconv_arm64.exe"
      FILENAME "texconv-${DIRECTXTEX_TAG}-arm64.exe"
      SHA512 27d92c44cd34421ba2c79da83a817c16ad67091286be3d64ad90dd0a3ceaf59c92c8268fe12293adbd6e84a22647eb50e74ec933365d5bf04a7bf391a9e13150
    )

    vcpkg_download_distfile(
      TEXDIAG_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texdiag_arm64.exe"
      FILENAME "texdiag-${DIRECTXTEX_TAG}-arm64.exe"
      SHA512 c179b7729bce61a20268fe69814fc3764104902748f98567e00c8d50860d515b94b1806caed4b07c76da1ddbb43390fa2d6c9cb33ad404456e05fde2b48a52a1
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
          SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin"
      )

  endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
