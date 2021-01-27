vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF jan2021b
    SHA512 bd327d0629bbae199f1b3fd80c0470b15edf221f204a4958b4e47b2b1a155b5c0e0af1cc1c39229d582363798f82efa91a3f63ec118fdb0e9255098a576b98ef
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
        FILENAME "DirectXTexEXR-1.cpp"
        SHA512 770fc0325b49139079b0bceb50619f93887e87a3dcf264b10dc01be16209fa51ba03d8273d4d4f84e596ac014376db96b7fed0afabe08c32394ed92495168ea6
    )

    file(COPY ${DIRECTXTEX_EXR_HEADER} DESTINATION ${SOURCE_PATH}/DirectXTex)
    file(COPY ${DIRECTXTEX_EXR_SOURCE} DESTINATION ${SOURCE_PATH}/DirectXTex)
    file(RENAME ${SOURCE_PATH}/DirectXTex/DirectXTexEXR-1.cpp ${SOURCE_PATH}/DirectXTex/DirectXTexEXR.cpp)
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

if((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))
  vcpkg_copy_tools(
        TOOL_NAMES texassemble texconv texdiag
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

elseif((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(
    TEXASSEMBLE_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/jan2021/texassemble.exe"
    FILENAME "texassemble-jan2021.exe"
    SHA512 0def8873358234ea4cd16acd59cb1dda2a8ad132f362502d643caed43e9aef19f9c7e7248494093cbd61e7501a9b44f545d3fbd5f50972ebcee3d01598a7c3b7
  )

  vcpkg_download_distfile(
    TEXCONV_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/jan2021/texconv.exe"
    FILENAME "texconv-jan2021.exe"
    SHA512 77559db65406ad0343901ff22f7647c4f270674f7b0c31b12d8dc26c718f410708ebe95bdc0ddba4049fa6cefd52ff856174530fc4170f9e725b30aacb78249c
  )

  vcpkg_download_distfile(
    TEXDIAG_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/jan2021/texdiag.exe"
    FILENAME "texdiag-jan2021.exe"
    SHA512 1b9e733050b5f92af86a9a2f415205acbff62f0708e491a3846d7b6e480a9c57086eff636be163d42a40a6d34dafc622cc53940797e7f6f77e739f3a66365f57
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(INSTALL
    ${TEXASSEMBLE_EXE}
    ${TEXCONV_EXE}
    ${TEXDIAG_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtex/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble-jan2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv-jan2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtex/texdiag-jan2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtex/texadiag.exe)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
