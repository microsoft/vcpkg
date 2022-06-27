vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF jun2022b
    SHA512 b72080d83ff894fcf5b9efd4f90715fc4a7d457150e1561a3093188d5533e4e856146f83277a5ddee8d7a84a193484cf9d13165a6a7ffb8ada931cf1ccb31eb3
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
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/jun2022/MakeSpriteFont.exe"
    FILENAME "makespritefont-jun2022.exe"
    SHA512 7cdc80e12a4a7be70733d582e4f613055a549345f83e24035cfce42d37568c4934c1bb68df5238f41df9d7fa0e84095aeb227d23450323e31a5d1d68cb505842
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/jun2022/XWBTool.exe"
    FILENAME "xwbtool-jun2022.exe"
    SHA512 b5782323e241641a429f66ad1ac511cfdfd6301851474dafdde274a4f93b49877406d5d0ab992097be7afe8db90fdb9488a9d6de5afce7e086df2e66a5bbca12
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont-jun2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-jun2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
