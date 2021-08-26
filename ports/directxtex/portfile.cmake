vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF aug2021
    SHA512 72b688848ad7645e018bb7dc3a3179ea3857e8349185ad53ad583b17aca555554ce44773a4b900ad163b2fd8551c28c3503b88333d8cff8f8d3ee03017bad35d
    HEAD_REF master
)

if("openexr" IN_LIST FEATURES)
    vcpkg_download_distfile(
        DIRECTXTEX_EXR_HEADER
        URLS "https://raw.githubusercontent.com/wiki/Microsoft/DirectXTex/DirectXTexEXR.h"
        FILENAME "DirectXTexEXR-2.h"
        SHA512 54163820996f7f3c47d0e34da7d717ba51a4363458d77e8f3750d2b6b38bcf803f199b913b4fd7b8dcdd3f520cd0c2bb42a9f79d30f5805fccdece6af368dd12
    )

    vcpkg_download_distfile(
        DIRECTXTEX_EXR_SOURCE
        URLS "https://raw.githubusercontent.com/wiki/Microsoft/DirectXTex/DirectXTexEXR.cpp"
        FILENAME "DirectXTexEXR-2.cpp"
        SHA512 fbf5a330961f3ac80e4425e8451e9a696240cd89fabca744a19f1f110ae188bae7d8eb5b058aaf66015066d919d4f581b14494d78d280147b23355d8a32745b9
    )

    file(COPY ${DIRECTXTEX_EXR_HEADER} DESTINATION ${SOURCE_PATH}/DirectXTex)
    file(COPY ${DIRECTXTEX_EXR_SOURCE} DESTINATION ${SOURCE_PATH}/DirectXTex)
    file(RENAME ${SOURCE_PATH}/DirectXTex/DirectXTexEXR-2.h ${SOURCE_PATH}/DirectXTex/DirectXTexEXR.h)
    file(RENAME ${SOURCE_PATH}/DirectXTex/DirectXTexEXR-2.cpp ${SOURCE_PATH}/DirectXTex/DirectXTexEXR.cpp)
    vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH} PATCHES enable_openexr_support.patch)
endif()

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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        ${EXTRA_OPTIONS}
        -DBC_USE_OPENMP=ON
        -DBUILD_DX11=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64) AND (NOT ("openexr" IN_LIST FEATURES)))
  vcpkg_download_distfile(
    TEXASSEMBLE_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/aug2021/texassemble.exe"
    FILENAME "texassemble-aug2021.exe"
    SHA512 11b07da257d7ea394fa789210b2985656bf28a0b6117d5380d9639ffc0a460a0e6c4bdbb24256dcf3b4d75088b4b5386951a7de856fecb99e73dfe326b4bfe45
  )

  vcpkg_download_distfile(
    TEXCONV_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/aug2021/texconv.exe"
    FILENAME "texconv-aug2021.exe"
    SHA512 c11bc77a36d5989189519793f3a44c15f1e01b3e0a6254bffca4ee6f96c933a6add34ffc7e409f3c3f97d862816006d3ca440876a4af200f035353d096902c5b
  )

  vcpkg_download_distfile(
    TEXDIAG_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/aug2021/texdiag.exe"
    FILENAME "texdiag-aug2021.exe"
    SHA512 73ae5fbc20ff7d970891d8e4029f1400f5d16675912cc4af97f9ef0e563dc77fa89690989e80eec5fd033975cf67d350be5a547d08fc5fecbabd4577603eef80
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(INSTALL
    ${TEXASSEMBLE_EXE}
    ${TEXCONV_EXE}
    ${TEXDIAG_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtex/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble-aug2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv-aug2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtex/texdiag-aug2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtex/texadiag.exe)

elseif((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))

  vcpkg_copy_tools(
        TOOL_NAMES texassemble texconv texdiag
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
