set(DIRECTXTEX_TAG mar2023)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF ${DIRECTXTEX_TAG}
    SHA512 2e3a0b6830988d1ca137f462d4eedde53d07f30b5eb4bbc8fc588819a1a4e2a220dd4d23efaf08dae225e23286a21c3054560485a6578037c6b355a9450901cd
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
    INVERTED_FEATURES
        no-omp BC_USE_OPENMP
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
      SHA512 0d22ca97567333142ebb612b16093270907853a6eb4ee583d497d62a2e11de0930144760c1674c3acd775fdaca2cf611dfa7878bf4634bd5913d9196c7dd4155
    )

    vcpkg_download_distfile(
      TEXCONV_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texconv.exe"
      FILENAME "texconv-${DIRECTXTEX_TAG}.exe"
      SHA512 b2dff6c3f4195c9cb25436b8fe9be467d5a6a07567f42d736532de90aad04b947e6a14d72c5fd2e9db3eaf33fcabb23dc13b1c604191b5fd51d544040e0107a9
    )

    vcpkg_download_distfile(
      TEXDIAG_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texdiag.exe"
      FILENAME "texdiag-${DIRECTXTEX_TAG}.exe"
      SHA512 b2617e12de22cb3369d29a2b1dc6f26275d2c325f4d0b388f05e7901c1d8d92fe029d73d24113c30a60729526f664f7d90234a4b0014185a9eadf88e09bc22fa
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
      SHA512 b5a8b53e2f481286ca8f1fdac5f03c0ccc07f282b0cdc83350e967a9e707adb6d3acd03c5edfb635f707a3044732ca942b490ed704bb869f5e7c21781cce7453
    )

    vcpkg_download_distfile(
      TEXCONV_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texconv_arm64.exe"
      FILENAME "texconv-${DIRECTXTEX_TAG}-arm64.exe"
      SHA512 3217719114eae1dabca27ab921574cee562e5e74e076a6fbf14d63ebd3e64d5d76948c926b2c2f15d6d4a6f26e5a0e57bbd3ad4075be0e7616b90d99db87d6e4
    )

    vcpkg_download_distfile(
      TEXDIAG_EXE
      URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texdiag_arm64.exe"
      FILENAME "texdiag-${DIRECTXTEX_TAG}-arm64.exe"
      SHA512 5425a8fa6aa7e806a14f5d10bcc78cb6c687b675bad98e4308aeec9daaf2babc5b57f33a8c83ea8db286716d52ae26219ab830552f5c26bcdfe75e4196cd274d
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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
