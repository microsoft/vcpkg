vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF nov2020b
    SHA512  9d936273284e0aa69c142865dbc25a04da3e316efae8172416424ce3bcb7a55c543a5f54b41e7a6bead264febb6d26227821648803f0682ec720a10059ccccdb
    HEAD_REF master
)

if("openexr" IN_LIST FEATURES)
    vcpkg_download_distfile(
        DIRECTXTEX_EXR_HEADER
        URLS "https://raw.githubusercontent.com/wiki/Microsoft/DirectXTex/DirectXTexEXR.h"
        FILENAME "DirectXTexEXR.h"
        SHA512 94ec71069949c8daa616d241ade0c771c448adab3e401a935d5462e7cac382cfbef47534072fc4b9706e086f5021de78a51fd4e2a6850cd3629c932592f9a168
    )

    vcpkg_download_distfile(
        DIRECTXTEX_EXR_SOURCE
        URLS "https://raw.githubusercontent.com/wiki/Microsoft/DirectXTex/DirectXTexEXR.cpp"
        FILENAME "DirectXTexEXR.cpp"
        SHA512 8bc66e102a0a163e42d428774c857271ad457a85038fd4ddfdbf083674879f9a8406a9aecd26949296b156a5c5fd08fdfba9600b71879be9affb9dabf23a497c
    )

    file(COPY ${DIRECTXTEX_EXR_HEADER} DESTINATION ${SOURCE_PATH}/DirectXTex)
    file(COPY ${DIRECTXTEX_EXR_SOURCE} DESTINATION ${SOURCE_PATH}/DirectXTex)
    vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH} PATCHES enable_openexr_support.patch)
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dx12 BUILD_DX12
        openexr ENABLE_OPENEXR_SUPPORT
)

if("openexr" IN_LIST FEATURES)
  set(FEATURE_OPTIONS ${FEATURE_OPTIONS} -DBUILD_TOOLS=ON)
else()
  set(FEATURE_OPTIONS ${FEATURE_OPTIONS} -DBUILD_TOOLS=OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBC_USE_OPENMP=ON
        -DBUILD_DX11=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

if("openexr" IN_LIST FEATURES)
  vcpkg_copy_tools(
        TOOL_NAMES texassemble texconv texdiag
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

else()
  vcpkg_download_distfile(texassemble
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/nov2020/texassemble.exe"
    FILENAME "texassemble.exe"
    SHA512 8094a4ef4a00df3d2cb4a18a1c84664f4a8bf018328751f19feef1691d1a3d9380556039b1a771728e55d94113baa0f69998f63c96a3b4a6f6c3ba9e53a29a64
  )

  vcpkg_download_distfile(texconv
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/nov2020/texconv.exe"
    FILENAME "texconv.exe"
    SHA512 91555fae9fadb942e8f3bc7052888fe515b1a0efb17f5eb53ef437e06c2e50baaef6a0552c93f218b028133baf65ba6e3393042a47b210baa9692ed6f8bbed2b
  )

  vcpkg_download_distfile(texdiag
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/nov2020/texdiag.exe"
    FILENAME "texdiag.exe"
    SHA512 7ba66004228ea1830fbfe5c40f4ee6cf1023f8256136a565c28e584a71115dd2d38e5f79f862de39ee54f8b34d7d8848c656082800f2a59f5b4833aee678d4b8
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(INSTALL
    ${DOWNLOADS}/texassemble.exe
    ${DOWNLOADS}/texconv.exe
    ${DOWNLOADS}/texdiag.exe
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtex/)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
