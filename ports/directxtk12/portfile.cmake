vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF feb2022
    SHA512 e61acd191b9ee5c7d76293f2feb158207f9e63d8f3d5a30144c04367c15d0c1d6a17d6905843d2ca80e9af713a83fa2ab2f52c206569993943997653ae6ad729
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DBUILD_XAUDIO_WIN10=ON -DBUILD_DXIL_SHADERS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(
    MAKESPRITEFONT_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/feb2022/MakeSpriteFont.exe"
    FILENAME "makespritefont-feb2022.exe"
    SHA512 d3454c679db269a29e845382f5cd9cceab2452aa91486238e38f79e71666718ea5d9fa1e676ffbe6875ee69310e17018690998dfb741530ea068fb0616fa4886
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/feb2022/XWBTool.exe"
    FILENAME "xwbtool-feb2022.exe"
    SHA512 f27170227be1268591757caaccda65d46ad81a2ac38ab1772d9e2d5c722a1d094a9b891f66fc6673d96a6b980a45c8fde501e2d9681f557039f8084ddf648aea
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont-feb2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-feb2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
