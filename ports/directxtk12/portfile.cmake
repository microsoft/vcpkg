vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF mar2022
    SHA512 fc41450aad51491f4ac89f87bfd76a62179052db1b98ee626561ef3edb8716578c8dfee01613731cdd9fd91f03ed54a8ec73595374ae16e217cfc87d6f11eca4
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
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/mar2022/MakeSpriteFont.exe"
    FILENAME "makespritefont-mar2022.exe"
    SHA512 a24f76781ddb2c9baa2550d3ef26bf4cf6cb03bfd97caa3b202232a04730fd81e299a9f3549c3ff58c03fda827e44deac5e0b311e8e3fc795e393651ecb51752
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/mar2022/XWBTool.exe"
    FILENAME "xwbtool-mar2022.exe"
    SHA512 32dd88e742211deaf0ca83e51ec510490456473c07fabbd6627960dc9abfa32289d99f2c8f53d7590a6a6733b3068ba25bff9a512fcf7d1072791dce931d463f
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont-mar2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-mar2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
