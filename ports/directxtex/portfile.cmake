vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_TARGET_IS_MINGW)
    message(NOTICE "Building ${PORT} for MinGW requires the HLSL Compiler fxc.exe also be in the PATH. See https://aka.ms/windowssdk.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF may2022
    SHA512 b5783c55a1faa9ac616f93d13af91d072e5cef65bcb02c402f2a4d072036135ae610264dc5ebe4e15c56b152c0b3fd0fb87666ab16e74507218906f4210687db
    HEAD_REF main
)

if("openexr" IN_LIST FEATURES)
    vcpkg_download_distfile(
        DIRECTXTEX_EXR_HEADER
        URLS "https://raw.githubusercontent.com/wiki/Microsoft/DirectXTex/DirectXTexEXR.h"
        FILENAME "DirectXTexEXR-3.h"
        SHA512 b4c75fa0e3365d63beba0ba471f0ded124b2f0e20f2c11cef76a88e6af1582889abcf5aa2ec74270d7b9bde7f7b4bc36fd17f030357b4139d8c83c35060344be
    )

    vcpkg_download_distfile(
        DIRECTXTEX_EXR_SOURCE
        URLS "https://raw.githubusercontent.com/wiki/Microsoft/DirectXTex/DirectXTexEXR.cpp"
        FILENAME "DirectXTexEXR-3.cpp"
        SHA512 9192cfea01654b1537b444cc6e3369de2f721959ad749551ad06ba92a12fa61e12f2169cf412788b0156220bb8bacf531160f924a4744e43e875163463586620
    )

    file(COPY ${DIRECTXTEX_EXR_HEADER} DESTINATION "${SOURCE_PATH}/DirectXTex")
    file(COPY ${DIRECTXTEX_EXR_SOURCE} DESTINATION "${SOURCE_PATH}/DirectXTex")
    file(RENAME "${SOURCE_PATH}/DirectXTex/DirectXTexEXR-3.h" "${SOURCE_PATH}/DirectXTex/DirectXTexEXR.h")
    file(RENAME "${SOURCE_PATH}/DirectXTex/DirectXTexEXR-3.cpp" "${SOURCE_PATH}/DirectXTex/DirectXTexEXR.cpp")
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
        -DBUILD_SAMPLE=OFF
        -DBC_USE_OPENMP=ON
        -DBUILD_DX11=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxtex/cmake)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64) AND (NOT ("openexr" IN_LIST FEATURES)))
  vcpkg_download_distfile(
    TEXASSEMBLE_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/may2022/texassemble.exe"
    FILENAME "texassemble-may2022.exe"
    SHA512 22963920f3047533d2ec6d9751f4d2eb4d530e6c4a96099322a070f5f311785d79d07c2e79fd05daa9992deba116f630de14436df4f42b415d7511fd6193241e
  )

  vcpkg_download_distfile(
    TEXCONV_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/may2022/texconv.exe"
    FILENAME "texconv-may2022.exe"
    SHA512 9f0c9307f00062883be8a2afff0f6428020d9f056db5a2f175ea3ff72e50f6fd5c57b2dbc448fe8352a86837b318bd3874995dc87d741bdeb413060618a0b08f
  )

  vcpkg_download_distfile(
    TEXDIAG_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/may2022/texdiag.exe"
    FILENAME "texdiag-may2022.exe"
    SHA512 01fc96ea5cc286dfea097d3b8bedb92d41dbbab949953315e640ee019578c33e2e1b0db476e51576c92763bacfa4cdf270ebad7cac1c59b185d5fdc0752f0393
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(INSTALL
    ${TEXASSEMBLE_EXE}
    ${TEXCONV_EXE}
    ${TEXDIAG_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble-may2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv-may2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texdiag-may2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texadiag.exe")

elseif((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))

  vcpkg_copy_tools(
        TOOL_NAMES texassemble texconv texdiag
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake"
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
