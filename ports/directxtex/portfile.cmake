vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF jun2021
    SHA512 aa67e814248b3e6163eb8670a8740831bc449b0cc1d83ba0e83d022cc3a8b78c92bc79dee15a089ef1d20566e22c4236ae871906b467bab688c223b32900ec60
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
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/jun2021/texassemble.exe"
    FILENAME "texassemble-jun2021.exe"
    SHA512 98fbd891b36c1f0c400670e4ad7943929a278995d1c1d99fe6c4d490abfabe001885eeafad3f913962c560a0ddd960126c979c60d89edcdf0dd002be919048d8
  )

  vcpkg_download_distfile(
    TEXCONV_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/jun2021/texconv.exe"
    FILENAME "texconv-jun2021.exe"
    SHA512 47719cca9a2eaf7b28da6b68f87c54ed89507e864d93a35ce7dc417dd0f40cbef23e54039c27c4addfbda79f2f94b1224172e6c8cf2b9ed1e784e60661900102
  )

  vcpkg_download_distfile(
    TEXDIAG_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/jun2021/texdiag.exe"
    FILENAME "texdiag-jun2021.exe"
    SHA512 484f582c01a001ad97dedecf9ac4be6602a82f52a4e22750dd8ee2c4fa09a776d74aa77b3e50339248dd547f832d293d6d789fabeafe9593271100085e838a86
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(INSTALL
    ${TEXASSEMBLE_EXE}
    ${TEXCONV_EXE}
    ${TEXDIAG_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtex/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble-jun2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv-jun2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtex/texdiag-jun2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtex/texadiag.exe)

elseif((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))

  vcpkg_copy_tools(
        TOOL_NAMES texassemble texconv texdiag
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
