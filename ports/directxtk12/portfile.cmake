vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF oct2021
    SHA512 b5b6b7d42967463bf941b41c9407417068761000344506b720e038f82b3a1aa6f44893695b2391075495d6a63eeb1d80cb011ed87e8f54430de3a77baa8cb570
    HEAD_REF master
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
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/oct2021/MakeSpriteFont.exe"
    FILENAME "makespritefont-oct2021.exe"
    SHA512 abff446bfd4cbddbca45816ec3a2230e52d9afb81c100966e4bce7e52a6e02620fd8cdcb416943090564885f63d33c4a246f43ff585c8f5686c2c9877ec50698
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/oct2021/XWBTool.exe"
    FILENAME "xwbtool-oct2021.exe"
    SHA512 fda62e06fb9998c41795c6be42f00a1048dcae302b20437f2a39350215789f77acfc77c0f1ebbc5bedeb986229c94f35bd1a03be37cdf4fcf4c007110f7efaa4
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont-oct2021.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-oct2021.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
