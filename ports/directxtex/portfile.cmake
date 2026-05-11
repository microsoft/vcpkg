set(DIRECTXTEX_TAG may2026)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF ${DIRECTXTEX_TAG}
    SHA512 0ff5c18418662f89d9b6efa07df118731404ca538ef456542ccfc287fd1fe1866e7fddc912a74c7e04861c6ec71ef8a47db75f3f8377aff14d0f49894492dec1
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
      SHA512 88f875b535f4477ecc37f26874692bf3608a49bc7b0af73febc65f67937c97c0dfb26b7fb729f172ded2b2c9ebf9285c9d2b1a1dbf3b88210ebe7d198c005d58
    )

    vcpkg_download_distfile(
      TEXCONV_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texconv.exe"
      FILENAME "texconv-${DIRECTXTEX_TAG}.exe"
      SHA512 aeaf50e4e531182ff44c3879fa68b6fbf43eda69a9c3e632e9a6d5ae74a8239301c406391ac0a9d4b9a1579f8a0571360ac1e20f01559997f644e19fd33ac4d9
    )

    vcpkg_download_distfile(
      TEXDIAG_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texdiag.exe"
      FILENAME "texdiag-${DIRECTXTEX_TAG}.exe"
      SHA512 da95189860c2d362cc17a2fdb20adb96952b3db40b6122c39b2aaa08fcf36024006e215328ba3e2c3d9b64cd2cf0ffc599b487554730732cf592a2aa2ac2105a
    )

    file(INSTALL
      "${TEXASSEMBLE_EXE}"
      "${TEXCONV_EXE}"
      "${TEXDIAG_EXE}"
      DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble-${DIRECTXTEX_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble.exe")
    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv-${DIRECTXTEX_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv.exe")
    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texdiag-${DIRECTXTEX_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texadiag.exe")

  elseif(((VCPKG_TARGET_ARCHITECTURE STREQUAL arm64) OR (VCPKG_TARGET_ARCHITECTURE STREQUAL arm64ec)) AND (NOT ("openexr" IN_LIST FEATURES)))

    vcpkg_download_distfile(
      TEXASSEMBLE_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texassemble_arm64.exe"
      FILENAME "texassemble-${DIRECTXTEX_TAG}-arm64.exe"
      SHA512 594a2cada333d69d24c6336e566c341633deeac519345f576b88b5e507c92130da4bc31ca9951d2fa22cae70487187cd6b8358fcee4bd3aaa8d9a55096b4a296
    )

    vcpkg_download_distfile(
      TEXCONV_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texconv_arm64.exe"
      FILENAME "texconv-${DIRECTXTEX_TAG}-arm64.exe"
      SHA512 3a47380255581b013e9223fcd7ddcd45d1215f27b8170294f64fc0a205c9640086c4130c9af9162b6e8d2de67f5d8507fd557ab4081bc562122ef6cfdc67de5d
    )

    vcpkg_download_distfile(
      TEXDIAG_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texdiag_arm64.exe"
      FILENAME "texdiag-${DIRECTXTEX_TAG}-arm64.exe"
      SHA512 8014c0b48465996ae9dff6879e0880fde1706e53df647fac7025f0a5a4023612ad9618ddd23c93d126fc5981fadfebe4c83967329c3cc3aaea4483f832dfe692
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

if("xbox" IN_LIST FEATURES)
    file(READ "${CMAKE_CURRENT_LIST_DIR}/xboxusage" USAGE_CONTENT)
    file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" ${USAGE_CONTENT})
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
