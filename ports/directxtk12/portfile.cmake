vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF aug2021
    SHA512 9d0234d7f8d631fa7cb434487bb1fbb4a52760550962f8ebd5a8c09b33cc2b328651b0c0355057e9b172b7445c86b083f33967ee7918a5eeaf19b3e4915dfe00
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
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/aug2021/MakeSpriteFont.exe"
    FILENAME "makespritefont-aug2021.exe"
    SHA512 a84786f57f7f26c4ab0cd446136d79c19a74296f5074396854c81ad67aedfccfe76e15025ba9bcfcabb993f0bb7247ca536d55b4574192efb3e7c2069abf70d7
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/aug2021/XWBTool.exe"
    FILENAME "xwbtool-aug2021.exe"
    SHA512 3dd1ebd04db21517f74453727512783141b997d33efc1a47236c9ff343310da17b4add4c4ba6e138ad35095fb77f4207e7458a9e51ee3f4872fc0e0cf62be5b5
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtk12/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont-aug2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-aug2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
