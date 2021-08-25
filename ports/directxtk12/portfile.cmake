vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF jun2021
    SHA512 8d33232a5422283a0a69850a7913b88ccbf9720e5172fe82171d38a0f42b487ba5cca4f356eeaee975bcbb931a5e7ddbce1c335c3c93f01e79f85d65613e5387
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_XAUDIO_WIN10=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(
    MAKESPRITEFONT_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/jun2021/MakeSpriteFont.exe"
    FILENAME "makespritefont-jun2021.exe"
    SHA512 4618090f65332c64cb5601a7095c60c87a3a41e9c030d7422d36f14b04dcd80c7aa26438733b892f91daf19fadd44591a814b77c3ca04590ad6c61ecbe909a65
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/jun2021/XWBTool.exe"
    FILENAME "xwbtool-jun2021.exe"
    SHA512 dc74081b9569a9ca736984d8da1a5b2dc852f85d07a629d6e0ef7f2b4313987ec82d2ff1e0cfa19a89c7387182644869ac2a8f842d30609d88ccae7c01ce3f80
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtk12/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont-jun2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-jun2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
