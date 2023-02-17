set(DIRECTXTEX_TAG jan2023)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF jan2023c
    SHA512 df550651b0fc4927aa9f837e0347b98722b8112ca7d7eddecded03a4a8a3dd7afed42c882c04f0b64e403a26c84d4e1c88ee9c104395be446ce220b28c6af9da
    HEAD_REF main
    )

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dx11 BUILD_DX11
        dx12 BUILD_DX12
        openexr ENABLE_OPENEXR_SUPPORT
        spectre ENABLE_SPECTRE_MITIGATION
)

if(VCPKG_TARGET_IS_MINGW AND ("dx11" IN_LIST FEATURES))
    message(NOTICE "Building ${PORT} for MinGW requires the HLSL Compiler fxc.exe also be in the PATH. See https://aka.ms/windowssdk.")
endif()

if (VCPKG_HOST_IS_LINUX)
    message(WARNING "Build ${PORT} requires GCC version 9 or later")
endif()

set(EXTRA_OPTIONS -DBUILD_SAMPLE=OFF -DBUILD_TESTING=OFF -DBC_USE_OPENMP=ON)

if(VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_XBOX)
  list(APPEND EXTRA_OPTIONS -DBUILD_TOOLS=OFF)
else()
  list(APPEND EXTRA_OPTIONS -DBUILD_TOOLS=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS} ${EXTRA_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxtex)

if(VCPKG_HOST_IS_WINDOWS AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64) AND (NOT ("openexr" IN_LIST FEATURES)))
  vcpkg_download_distfile(
    TEXASSEMBLE_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texassemble.exe"
    FILENAME "texassemble-${DIRECTXTEX_TAG}.exe"
    SHA512 a339b725107d8b45e73e2cf24a989844a98a28cda2a01ff760cc46dea49f09b27b5d8d4c1c6940b323b0d0cc83492d21895a958e11ba82a0bbfdd877bfad7ded
  )

  vcpkg_download_distfile(
    TEXCONV_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texconv.exe"
    FILENAME "texconv-${DIRECTXTEX_TAG}.exe"
    SHA512 6dc472cec94c771bb289a927ee0cce0507332394353306806a7d244999591f9f7c46dd86a55cf24c727fb0592f777b2a4df4f4edaecc72c40ee72a00830372f2
  )

  vcpkg_download_distfile(
    TEXDIAG_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/${DIRECTXTEX_TAG}/texdiag.exe"
    FILENAME "texdiag-${DIRECTXTEX_TAG}.exe"
    SHA512 512346a880459179fb585dfb2ca97ef6a668e803be201de180e6ca3e431c61b73204f80cabe9b3aced97a33abdfd831cce56eb9228726db5ae9fe993c59845a6
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(INSTALL
    ${TEXASSEMBLE_EXE}
    ${TEXCONV_EXE}
    ${TEXDIAG_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble-${DIRECTXTEX_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv-${DIRECTXTEX_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtex/texdiag-${DIRECTXTEX_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtex/texadiag.exe")

elseif(VCPKG_TARGET_IS_WINDOWS AND (NOT VCPKG_TARGET_IS_UWP) AND (NOT VCPKG_TARGET_IS_XBOX) AND ("dx11" IN_LIST FEATURES))

  vcpkg_copy_tools(
        TOOL_NAMES texassemble texconv texdiag
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake"
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
