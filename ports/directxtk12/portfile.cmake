vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF jan2021
    SHA512 a6938194bc8857fe0076cb21f000aaa4ab4e207342e07f76ecea9d3f064c1b0c220a5f410c2e1184f37d98b54ef2f4852a6bc7cb13a029885bd3c39cb3f1a727
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
  vcpkg_download_distfile(makespritefont
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/jan2021/MakeSpriteFont.exe"
    FILENAME "makespritefont.exe"
    SHA512 0cca19694fd3625c5130a85456f7bf1dabc8c5f893223c19da134a0c4d64de853f7871644365dcec86012543f3a59a96bfabd9e51947648f6d82480602116fc4
  )

  vcpkg_download_distfile(xwbtool
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/jan2021/XWBTool.exe"
    FILENAME "xwbtool.exe"
    SHA512 91c9d0da90697ba3e0ebe4afcc4c8e084045b76b26e94d7acd4fd87e5965b52dd61d26038f5eb749a3f6de07940bf6e3af8e9f19d820bf904fbdb2752b78fce9
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(INSTALL
    ${DOWNLOADS}/makespritefont.exe
    ${DOWNLOADS}/xwbtool.exe
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtk12/)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
