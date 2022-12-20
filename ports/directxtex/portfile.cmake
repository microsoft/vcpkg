set(DIRECTXTEX_TAG oct2022)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_TARGET_IS_MINGW)
    message(NOTICE "Building ${PORT} for MinGW requires the HLSL Compiler fxc.exe also be in the PATH. See https://aka.ms/windowssdk.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF oct2022b
    SHA512 48db2d88f84cda0692e887d5b26fb6051649eae2f9699803170926a9660abaf836f567b2dacdf4900a7a041c22e936d612615247825e256f840808e5ae497e4d
    HEAD_REF main
    )

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dx12 BUILD_DX12
        openexr ENABLE_OPENEXR_SUPPORT
)

if (VCPKG_HOST_IS_LINUX)
    message(WARNING "Build ${PORT} requires GCC version 9 or later")
endif()

if(VCPKG_TARGET_IS_UWP)
  set(EXTRA_OPTIONS -DBUILD_TOOLS=OFF)
else()
  set(EXTRA_OPTIONS -DBUILD_TOOLS=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${EXTRA_OPTIONS}
        -DBUILD_SAMPLE=OFF
        -DBC_USE_OPENMP=ON
        -DBUILD_DX11=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxtex)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64) AND (NOT ("openexr" IN_LIST FEATURES)))
  vcpkg_download_distfile(
    TEXASSEMBLE_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texassemble.exe"
    FILENAME "texassemble-${DIRECTXTEX_TAG}.exe"
    SHA512 cdf2394c83900fa09f4d8c127863223891fb713090c18407fd83581fdd3e476292cfca4e5accaaa66310d62e03c2836bddac37e508aecb1c2a2346d35eecf08b
  )

  vcpkg_download_distfile(
    TEXCONV_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texconv.exe"
    FILENAME "texconv-${DIRECTXTEX_TAG}.exe"
    SHA512 d2c5899a2b4abea5e975699326143f198c04808f9ac5b19c0580618601ed671b12eaef846938142bfa22eb7338ad7fabbdaadff76bc1776f543ecbd33b8d2586
  )

  vcpkg_download_distfile(
    TEXDIAG_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texdiag.exe"
    FILENAME "texdiag-${DIRECTXTEX_TAG}.exe"
    SHA512 99e9073c6a22b54b56337dfaa18c6723febe6ca65b1e8b53a64dadee149e06111511115bf06aca95ad4b30a5cc24da9d7b526260f7c58e38740a38ff7a6e007b
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(INSTALL
    ${TEXASSEMBLE_EXE}
    ${TEXCONV_EXE}
    ${TEXDIAG_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble-${DIRECTXTEX_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv-${DIRECTXTEX_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texdiag-${DIRECTXTEX_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texadiag.exe")

elseif((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))

  vcpkg_copy_tools(
        TOOL_NAMES texassemble texconv texdiag
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake"
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
