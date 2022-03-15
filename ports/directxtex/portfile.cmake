vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF feb2022
    SHA512 7e30e38f97e944e49f5d2a6d3035d201016ac7ec5ca1042475485f7cbac165d66f4c5a2c84f2a47dad755c59b3f8947e1251b00b3e577fbc3e58f1957d8a224e
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
        -DBC_USE_OPENMP=ON
        -DBUILD_DX11=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64) AND (NOT ("openexr" IN_LIST FEATURES)))
  vcpkg_download_distfile(
    TEXASSEMBLE_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/feb2022/texassemble.exe"
    FILENAME "texassemble-feb2022.exe"
    SHA512 ea1f9fff62a5ebc9c33221852a843063d58405be7529f663e4567b138bca79e73e47b1e0fb6054c4e024a630323c72aba505eee35414cf14970c331afa9ff43f
  )

  vcpkg_download_distfile(
    TEXCONV_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/feb2022/texconv.exe"
    FILENAME "texconv-feb2022.exe"
    SHA512 1565f5a4bd08de88e01ece59df6658975bfd8551a912d65ac03c0ddd5ab536c8794811d3e49d14e8fe4c61fa2a6c9d50994d372f5d3efab7d9aeb6f3f92d56c9
  )

  vcpkg_download_distfile(
    TEXDIAG_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/feb2022/texdiag.exe"
    FILENAME "texdiag-feb2022.exe"
    SHA512 5dd93da696eff959b5c93ba8ac763ff6df52fbfc6ca3a3adf1b9da0121beaea2c16008e097f74d562b7a69ed20ada50fd5d35d47311338e6c819e3483bc54ee3
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(INSTALL
    ${TEXASSEMBLE_EXE}
    ${TEXCONV_EXE}
    ${TEXDIAG_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble-feb2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv-feb2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texdiag-feb2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texadiag.exe")

elseif((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))

  vcpkg_copy_tools(
        TOOL_NAMES texassemble texconv texdiag
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake"
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
