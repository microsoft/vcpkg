vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF apr2021
    SHA512 5bca666815567f681420c4b4e8b1b801a3bdfaf8f00f0910c9d697c90d6c75d74d0ecf9f8c820cca5f94756c5e3796bc3fd936a8b695953af20ffd0c0c0b1b96
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
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/apr2021/MakeSpriteFont.exe"
    FILENAME "makespritefont-apr2021.exe"
    SHA512 f958dc0a88ff931182914ebb4b935d4ed71297d59a61fb70dbf7769d22350abc712acfdbbfbba658781600c83ac7e390eac0663ade747f749194addd209c5bfa
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/apr2021/XWBTool.exe"
    FILENAME "xwbtool-apr2021.exe"
    SHA512 8918fe7f5c996a54c6a5032115c9b82c6fe9b61688da3cde11c0282061c17a829639b219b8ff5ac623986507338c927eb926f2c42ba3c98563dfe7e162e22305
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtk12/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont-apr2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-apr2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
