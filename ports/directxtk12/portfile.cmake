vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF sept2021
    SHA512 bb8a8a81381a6638e33cefc0c058126843df79cf84fd9a248606e965048ba6faae23e8167eb91dd6b8e9a11a788b188067877ef26852c6530ef6fc3c50b221b4
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_XAUDIO_WIN10=ON -DBUILD_DXIL_SHADERS=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(
    MAKESPRITEFONT_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/sept2021/MakeSpriteFont.exe"
    FILENAME "makespritefont-sept2021.exe"
    SHA512 a22ec8e7d283585574a5aec82c937c2844e89e66ded01fea92bb278beb7ff32c8070fa3016192029ed8c106db7ef0356f867521a2603a4de7c085cd8db693d0a
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/sept2021/XWBTool.exe"
    FILENAME "xwbtool-sept2021.exe"
    SHA512 40f33af95bfdaf60a41564dc347d51768774ad7caa8529046e3f87256e80e165aa124b21193d0ffa1e94644343006d6de01807df317dfdf13377a31275b973ef
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtk12/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont-sept2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-sept2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
