set(DIRECTXTEX_TAG oct2023)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF ${DIRECTXTEX_TAG}
    SHA512 4521d716bc903e9373c8d2929ff4fec04b3ae276a3005a06a744d5ee7044520faec6aa06e166b9c3bcc18f68c8e7553f23b21c227154eb3ef994a1c68b57da1a
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

set(EXTRA_OPTIONS -DBUILD_SAMPLE=OFF -DBUILD_TESTING=OFF)

if(VCPKG_TARGET_IS_WINDOWS AND NOT (VCPKG_TARGET_IS_XBOX OR VCPKG_TARGET_IS_MINGW) AND NOT "dx12" IN_LIST FEATURES)
  list(APPEND EXTRA_OPTIONS "-DCMAKE_DISABLE_FIND_PACKAGE_directx-headers=TRUE")
endif()

if(VCPKG_TARGET_IS_MINGW AND ("dx11" IN_LIST FEATURES))
    message(NOTICE "Building ${PORT} for MinGW requires the HLSL Compiler fxc.exe also be in the PATH. See https://aka.ms/windowssdk.")
endif()

if (VCPKG_HOST_IS_LINUX)
    message(WARNING "Build ${PORT} requires GCC version 9 or later")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS} ${EXTRA_OPTIONS}
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
      SHA512 e53548f8715f9ecfe7bd9904eec5fd2fe77d09e8fae78fa95a056a882d8856fe9311d01a703da47ef530e3878fdee8bc4a288617a81ffb61043d6b48acef5df0
    )

    vcpkg_download_distfile(
      TEXCONV_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texconv.exe"
      FILENAME "texconv-${DIRECTXTEX_TAG}.exe"
      SHA512 ca1772650f7368917ea719d853eade2040ed189c45acb8cbaa1dec57e61ca429e041b411271a53e9ca9a11f7a5fc84df1e25c0d019886647b8208bdde93ff258
    )

    vcpkg_download_distfile(
      TEXDIAG_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texdiag.exe"
      FILENAME "texdiag-${DIRECTXTEX_TAG}.exe"
      SHA512 baea51318adec86e7d0808c99c5ed8d529d9196073ce31c7df79fc12c7ff085169ab72d8876a47bc462d4eb6ec02e103af3f8b1ee0fdd762c2662c0453388e74
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
      SHA512 d11152bf4193ab83ab8cabae58ef517b05babec049f2fb1317a51b708d14ba4a93806ff4ebeb1004391c0692fc76b9bedd7a43dbea3d74a4d7548fb69c809f8b
    )

    vcpkg_download_distfile(
      TEXCONV_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texconv_arm64.exe"
      FILENAME "texconv-${DIRECTXTEX_TAG}-arm64.exe"
      SHA512 09f3bc8aebac8804644f6673d0f21d4ee21155f13383c5a0da8afcaef6df6a1186c9254679334247b638ec11b9f1080abed285e174716a1e7662fc46c103278d
    )

    vcpkg_download_distfile(
      TEXDIAG_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texdiag_arm64.exe"
      FILENAME "texdiag-${DIRECTXTEX_TAG}-arm64.exe"
      SHA512 d1ec122e9647d243349678b8d1d267d9b26a84a6a845728c0408f94a486fe6c43488b2f507a96035063fc245bcb670367c0f219626c627ddc31d1713a782a1fd
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
