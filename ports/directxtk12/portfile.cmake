vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF nov2021
    SHA512 c47dbc877599ad09240d182301198e0d8074ce319abf38958372d13c06a2a1921e2aff6c3acfb0a37a44be681933d1e86542da8491a5ca3f2b9c33fdca73beef
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
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/nov2021/MakeSpriteFont.exe"
    FILENAME "makespritefont-nov2021.exe"
    SHA512 0aab40aced022588d9c1089c5b2f297b0521497d0ae559ead98f99e1e73f2daf9f38ebecadb413095abd2a6c207183fbca582d47528c6f21258df3ac391134e5
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/nov2021/XWBTool.exe"
    FILENAME "xwbtool-nov2021.exe"
    SHA512 f2f291c496500e593c0a4795fee9fafc685666682f23a38a25546bb67ec083533a26f2ce0562b819abea44bd8b403a2f246fbf978e366c457eb8a0f836fd5a2e
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont-nov2021.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-nov2021.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
