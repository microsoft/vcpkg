vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF jul2022
    SHA512 54e58e181fec16f6bc9b27ad9e8267bc23601912f18759d99b278c4086cc0979ff18fe80db8ee7cbb9dfa7e38d0c892b665f005ffbb60f9d0ccdbe69093b6b5d
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        xaudio2-9 BUILD_XAUDIO_WIN10
        xaudio2redist BUILD_XAUDIO_REDIST
)

set(DXCPATH ${CURRENT_HOST_INSTALLED_DIR}/tools/directx-dxc)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS} -DBUILD_DXIL_SHADERS=ON -DDIRECTX_DXC_PATH=${DXCPATH}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxtk12)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(
    MAKESPRITEFONT_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/jul2022/MakeSpriteFont.exe"
    FILENAME "makespritefont-jul2022.exe"
    SHA512 fd039070fad3dee3fe146d2cd4950f599f680cb4abd370e7c21bedeb8c0a970455ad2eac463fc6d198505b6bbdabebfcc453bf74c317f6a10bf2e2f9a0bfc418
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/jul2022/XWBTool.exe"
    FILENAME "xwbtool-jul2022.exe"
    SHA512 6276e17241afc8c0b82789b99667577394eedf001fa2d4b3acdfac847744c3ac5ec9a8072a1e3e9f247386711232aab93f066a0689f4f9f7d84744dc3862ea05
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont-jul2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-jul2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
