vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF jan2021b
    SHA512 19e017f11fb6cd25a10fbf2597d1a0fe133a339781f5b1b333eb52224fcf5869c5e5bb5a3f3a2f57ffad527076e6780cccccfbae09c48abfce3010be688b87b5
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
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/jan2021/MakeSpriteFont.exe"
    FILENAME "makespritefont-jan2021.exe"
    SHA512 0cca19694fd3625c5130a85456f7bf1dabc8c5f893223c19da134a0c4d64de853f7871644365dcec86012543f3a59a96bfabd9e51947648f6d82480602116fc4
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/jan2021/XWBTool.exe"
    FILENAME "xwbtool-jan2021.exe"
    SHA512 91c9d0da90697ba3e0ebe4afcc4c8e084045b76b26e94d7acd4fd87e5965b52dd61d26038f5eb749a3f6de07940bf6e3af8e9f19d820bf904fbdb2752b78fce9
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtk12/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont-jan2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-jan2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
