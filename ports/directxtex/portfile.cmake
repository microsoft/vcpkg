vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF sept2021
    SHA512 5fe5ed64fd58d9b881b186d3ca0fcac7980afc214eb219f842607d4b868b14c1411613a46d74d3cd9ab242d533dfa0ac8c181d083391c665a4577e4c3b931100
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
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/sept2021/texassemble.exe"
    FILENAME "texassemble-sept2021.exe"
    SHA512 05539bae0f77bba1e6fa349ac483367d3f34f808857fd3c3bdecd2a956465101dbaec95cb4e61c15d5d65fd12cdc14fab17cede3a2719dc32bda8748b7a1c59a
  )

  vcpkg_download_distfile(
    TEXCONV_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/sept2021/texconv.exe"
    FILENAME "texconv-sept2021.exe"
    SHA512 9ec2415d2d1b665a0a67c01c916afb5946dedede3518e3a029b83e4a8bb86d8f22b2dc0afdc7dbe0824f8f9843a86e555f3e4705570703d4447a47f2719f5b5a
  )

  vcpkg_download_distfile(
    TEXDIAG_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/sept2021/texdiag.exe"
    FILENAME "texdiag-sept2021.exe"
    SHA512 380660fa46438368a0f30684e0b9d9f4c267d76145bacbf4e5643889e00f869b0925250c1911397ce6a3890752de87f6105ef0e60d0e0334eb36fbc7f53deea7
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(INSTALL
    ${TEXASSEMBLE_EXE}
    ${TEXCONV_EXE}
    ${TEXDIAG_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtex/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble-sept2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv-sept2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtex/texdiag-sept2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtex/texadiag.exe)

elseif((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))

  vcpkg_copy_tools(
        TOOL_NAMES texassemble texconv texdiag
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
