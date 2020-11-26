vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF nov2020
    SHA512 a3f4abc2729c6e98b8cd29ff1d410410bced2eaa2dc62563f18344dbb33f30d7ce32c11cafe85f91786e80610d8a2030dab48919f5bf9ccf92ceba2c5ed4db13
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBC_USE_OPENMP=ON
        -DBUILD_DX11=ON
)

if(NOT VCPKG_TARGET_IS_UWP AND NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    vcpkg_build_cmake()
else()
    vcpkg_build_cmake(TARGET DirectXTex)
endif()

file(INSTALL ${SOURCE_PATH}/DirectXTex/DirectXTex.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/DirectXTex/DirectXTex.inl DESTINATION ${CURRENT_PACKAGES_DIR}/include)
if("openexr" IN_LIST FEATURES)
    file(INSTALL ${SOURCE_PATH}/DirectXTex/DirectXTexEXR.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
endif()

file(GLOB_RECURSE DEBUG_LIB ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin/CMake/*.lib)
file(GLOB_RECURSE RELEASE_LIB ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake/*.lib)
file(INSTALL ${DEBUG_LIB} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL ${RELEASE_LIB} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
if(NOT VCPKG_TARGET_IS_UWP AND NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
  vcpkg_copy_tools(
        TOOL_NAMES texassemble texconv texdiag
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
