set(DIRECTXTEX_TAG mar2026)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF ${DIRECTXTEX_TAG}
    SHA512 9aadfb8b1b68fe858260dc455550f6c0945b95fa7bd459e15428c56612b0a87977eeda3d62810fc7f3c2076ab14e20028891daf9b6d7e75e9c12726decfd8983
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
      SHA512 6b7621fdf41301ce343132a1bd0a48cada0cf0b50f71c3c078c650b1fd0df634b46531ec8a8192ea704417fcddc6d62817753e0566259f81963b9f5166a87ce9
    )

    vcpkg_download_distfile(
      TEXCONV_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texconv.exe"
      FILENAME "texconv-${DIRECTXTEX_TAG}.exe"
      SHA512 19cc5986a50bea0e8a33dcae26d797f8cbe3750bdb4fe3aacff73b65f04cfc6a059667d69f46a720883958c46d7580de97d7537ba6c1a5ef6e90498af94e07ba
    )

    vcpkg_download_distfile(
      TEXDIAG_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texdiag.exe"
      FILENAME "texdiag-${DIRECTXTEX_TAG}.exe"
      SHA512 1aaa71a9fe6607b57f64bf8f651752489a05c24a69f182de9a59ecf6c095476aaadc62f80a75a47d19de705a7ba049924417330e3aeaeeccda8b748234d3456d
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
      SHA512 475abce513a6c91b4e7a89ac9b9b3042e1f63275cdcb411a0a66499bceec0511d539bca3ef4ed48db2f6a34d2d497b3f82e201165d1855c87657d23461d9c314
    )

    vcpkg_download_distfile(
      TEXCONV_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texconv_arm64.exe"
      FILENAME "texconv-${DIRECTXTEX_TAG}-arm64.exe"
      SHA512 f13f6350d58b5359dc0dd2421a158514bb89905168544e8a38da32b3fa9e0f2a4e654adf6b25d0721f598c4aa6e932e2a2f5ea3f634cc2cc67468817610884ef
    )

    vcpkg_download_distfile(
      TEXDIAG_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texdiag_arm64.exe"
      FILENAME "texdiag-${DIRECTXTEX_TAG}-arm64.exe"
      SHA512 5e28b0798ce9a5a0d76bdaaaeb7fd3d170f85d3ff68ba16dc920bcb2bf277436f866a5a505ac112781582855ad352e187f02e6dd914bf4610a7070ca78c99e00
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
