vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF sept2020
    SHA512 f6b5b07817c05c64a5281b0006b182f2ebd110d79f10332801b51a185486fd7426e18c454e66995e9f88c92d7b8cf0c03ae590aa040d92314bdd3d4989784156
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
    FEATURES openexr ENABLE_OPENEXR_SUPPORT
)

if("dx12" IN_LIST FEATURES OR VCPKG_TARGET_IS_UWP OR TRIPLET_SYSTEM_ARCH STREQUAL "arm64")
    list(APPEND FEATURE_OPTIONS -DBUILD_DX12=ON)
else()
    list(APPEND FEATURE_OPTIONS -DBUILD_DX12=OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBC_USE_OPENMP=ON
        -DBUILD_DX11=ON
)

if(NOT VCPKG_TARGET_IS_UWP AND NOT TRIPLET_SYSTEM_ARCH STREQUAL "arm64")
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
if(NOT VCPKG_TARGET_IS_UWP AND NOT TRIPLET_SYSTEM_ARCH STREQUAL "arm64")
  vcpkg_copy_tools(
        TOOL_NAMES texassemble texconv texdiag
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
