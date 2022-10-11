vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_TARGET_IS_MINGW)
    message(NOTICE "Building ${PORT} for MinGW requires the HLSL Compiler fxc.exe also be in the PATH. See https://aka.ms/windowssdk.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF jul2022
    SHA512 21b21dfff8bbedabfcb7d3694d750370304382ce0a9847c4ff3c153a3b6a6c5b61fc4051eb95b210e186107092488572757c43e1ca37319e763d49b0bca49dd4
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
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxtex)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64) AND (NOT ("openexr" IN_LIST FEATURES)))
  vcpkg_download_distfile(
    TEXASSEMBLE_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/jul2022/texassemble.exe"
    FILENAME "texassemble-jul2022.exe"
    SHA512 72b47e30f810481f2af00cf45eb5789ae78c3ce0cc385f8168a74f178798cefa69b837060fe0ff4cf8dedaf8d1e489bbf4b3e1453c821df478636aca73f89b43
  )

  vcpkg_download_distfile(
    TEXCONV_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/jul2022/texconv.exe"
    FILENAME "texconv-jul2022.exe"
    SHA512 6fe66d90a33510005f3dcc0190aef4e0139d077ee7aeeef015b1e9204149384d46d02e0d9274b68e6f4299b64d3c4eb57fc4bfa6bfefc317699e624ae332abb6
  )

  vcpkg_download_distfile(
    TEXDIAG_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/jul2022/texdiag.exe"
    FILENAME "texdiag-jul2022.exe"
    SHA512 804a361293b5350d722604f5150a72751e1c25642986a505e83e0b33be8f53535ea42b6adbbc0b0b88e16d494012e9d02150c60e0ce0115fba30a84e7c2a14bd
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(INSTALL
    ${TEXASSEMBLE_EXE}
    ${TEXCONV_EXE}
    ${TEXDIAG_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble-jul2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv-jul2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texdiag-jul2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texadiag.exe")

elseif((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))

  vcpkg_copy_tools(
        TOOL_NAMES texassemble texconv texdiag
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake"
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
