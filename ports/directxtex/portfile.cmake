vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF mar2022
    SHA512 04f898b2cf2c76edd400147db9144e196fc8441739de3293f8851952ce8153bab033deba52a0d35e51c4fbc9705ffe183f1606a0fae29970dc2babe65ed78e19
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
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/mar2022/texassemble.exe"
    FILENAME "texassemble-mar2022.exe"
    SHA512 2a2bec1f012ba6778d99f53a3b4f015f84e4ab76dd68a1980d77cdac588c60a21b30abbfc0de9f0b0ef790ef5ed8444f1648b80990053f8a1f967a04d20d3c33
  )

  vcpkg_download_distfile(
    TEXCONV_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/mar2022/texconv.exe"
    FILENAME "texconv-mar2022.exe"
    SHA512 fa0b12dcc7e4688f356bb591dedd07dcb27b6029c6490438b39368f72b77f90112360544e035f89e1098dc09b26fb921840ecae851ad5eba6a339cd46316c4e3
  )

  vcpkg_download_distfile(
    TEXDIAG_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/mar2022/texdiag.exe"
    FILENAME "texdiag-mar2022.exe"
    SHA512 7fe074a08599edca9ad8ad5ff930c9c4dbc74faad6502c288e9a555a4a79f51affbce51758c99518d54c4698457e0edb379ffaebfd3dcae0bd16a343195f8292
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(INSTALL
    ${TEXASSEMBLE_EXE}
    ${TEXCONV_EXE}
    ${TEXDIAG_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble-mar2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv-mar2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texdiag-mar2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texadiag.exe")

elseif((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))

  vcpkg_copy_tools(
        TOOL_NAMES texassemble texconv texdiag
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake"
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
