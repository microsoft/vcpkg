vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF nov2021b
    SHA512 7f9b17e265836933c02b98c613e7c0503a74a6c3c1d97552bfbaf2f060b500019c74def80694f5e2ad6250f8bcceeac17677f264f677ff46851a9020ab604353
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

    file(COPY ${DIRECTXTEX_EXR_HEADER} DESTINATION "${SOURCE_PATH}/DirectXTex")
    file(COPY ${DIRECTXTEX_EXR_SOURCE} DESTINATION "${SOURCE_PATH}/DirectXTex")
    file(RENAME "${SOURCE_PATH}/DirectXTex/DirectXTexEXR-2.h" "${SOURCE_PATH}/DirectXTex/DirectXTexEXR.h")
    file(RENAME "${SOURCE_PATH}/DirectXTex/DirectXTexEXR-2.cpp" "${SOURCE_PATH}/DirectXTex/DirectXTexEXR.cpp")
    vcpkg_apply_patches(SOURCE_PATH "${SOURCE_PATH}" PATCHES enable_openexr_support.patch)
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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${EXTRA_OPTIONS}
        -DBC_USE_OPENMP=ON
        -DBUILD_DX11=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64) AND (NOT ("openexr" IN_LIST FEATURES)))
  vcpkg_download_distfile(
    TEXASSEMBLE_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/nov2021/texassemble.exe"
    FILENAME "texassemble-nov2021.exe"
    SHA512 a31151d368d41f50b58b417e8d27987fe0e3caa2c4e0d0abe7bef472db51429526277b0c554df2825c6892bb2021111f59d3d8f321ad68c71c0a153852d2c81f
  )

  vcpkg_download_distfile(
    TEXCONV_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/nov2021/texconv.exe"
    FILENAME "texconv-nov2021.exe"
    SHA512 7cb70b3cbf46c78b99aa18c28b043fc5930b6b254729efd447868fcf8cb8b77987d41b570082bdfb3bab01452e67d17e81b966bf2534036a3415fa918ddc2956
  )

  vcpkg_download_distfile(
    TEXDIAG_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/nov2021/texdiag.exe"
    FILENAME "texdiag-nov2021.exe"
    SHA512 7826c594fa42978da8a15bd771fafe4d4f5b97d611ce62a806ddff77204cabf63eea6ac24e3409c2720631681260b7e3fa6ad5f33b2162d2266457462e6b13c9
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(INSTALL
    ${TEXASSEMBLE_EXE}
    ${TEXCONV_EXE}
    ${TEXDIAG_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble-nov2021.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv-nov2021.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texdiag-nov2021.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texadiag.exe")

elseif((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))

  vcpkg_copy_tools(
        TOOL_NAMES texassemble texconv texdiag
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake"
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
