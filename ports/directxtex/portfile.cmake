set(DIRECTXTEX_TAG dec2022)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_TARGET_IS_MINGW)
    message(NOTICE "Building ${PORT} for MinGW requires the HLSL Compiler fxc.exe also be in the PATH. See https://aka.ms/windowssdk.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF dec2022b
    SHA512 353ac25b77218e7e7f11495d51bf10552444f71b2dd3a13e64264328fd8814fb3d65704dc7c517ff349a5143e9c454ae6a7782c16dc74f992b0ae9d517daa404
    HEAD_REF main
    )

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dx12 BUILD_DX12
        openexr ENABLE_OPENEXR_SUPPORT
        spectre ENABLE_SPECTRE_MITIGATION
)

if (VCPKG_HOST_IS_LINUX)
    message(WARNING "Build ${PORT} requires GCC version 9 or later")
endif()

set(EXTRA_OPTIONS -DBUILD_SAMPLE=OFF -DBUILD_TESTING=OFF -DBC_USE_OPENMP=ON -DBUILD_DX11=ON)

if(VCPKG_TARGET_IS_UWP)
  list(APPEND EXTRA_OPTIONS -DBUILD_TOOLS=OFF)
else()
  list(APPEND EXTRA_OPTIONS -DBUILD_TOOLS=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS} ${EXTRA_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxtex)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64) AND (NOT ("openexr" IN_LIST FEATURES)))
  vcpkg_download_distfile(
    TEXASSEMBLE_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texassemble.exe"
    FILENAME "texassemble-${DIRECTXTEX_TAG}.exe"
    SHA512 78f556d6fa7808f6c22b6b1fa130c7c0c694ab8011ebb2ed633d3f35b281b39a2aee2c171da665ccbbbc49be1af6e90bdecc7d837a789aac5d9ef54afd2d0951
  )

  vcpkg_download_distfile(
    TEXCONV_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texconv.exe"
    FILENAME "texconv-${DIRECTXTEX_TAG}.exe"
    SHA512 6bd3f5d9a986887b618d3cb2c765f29c8e632f70df96c60ee3492bed26f1f3407e5293177c479b7f80d8178491dbe22b25737b34e426712e6e1dede7eebb84df
  )

  vcpkg_download_distfile(
    TEXDIAG_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texdiag.exe"
    FILENAME "texdiag-${DIRECTXTEX_TAG}.exe"
    SHA512 e443407d69e628341d72b18a6ae2ebddf69d0554c468a7aa77e2dbf87a4498c4cefe59be709d9d786c7a940ac4cc523e95a31a1a8fd056b103045ef0412f3775
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
