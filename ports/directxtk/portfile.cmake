vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF mar2022
    SHA512 09264e19ff786b1f8cf56f0a789ce9df60b3682adba6dbb3e9c8c8c7d869b464c0ad869299fc5cda2d535db19c7a96b43cba2fd40d8cb6aa9dc14914b181d410
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        xaudio2-9 BUILD_XAUDIO_WIN10
        xaudio2-8 BUILD_XAUDIO_WIN8
        xaudio2redist BUILD_XAUDIO_WIN7
)

if(VCPKG_TARGET_IS_UWP)
  set(EXTRA_OPTIONS -DBUILD_TOOLS=OFF)
else()
  set(EXTRA_OPTIONS -DBUILD_TOOLS=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS} ${EXTRA_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(
    MAKESPRITEFONT_EXE
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/mar2022/MakeSpriteFont.exe"
    FILENAME "makespritefont-mar2022.exe"
    SHA512 a24f76781ddb2c9baa2550d3ef26bf4cf6cb03bfd97caa3b202232a04730fd81e299a9f3549c3ff58c03fda827e44deac5e0b311e8e3fc795e393651ecb51752
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/mar2022/XWBTool.exe"
    FILENAME "xwbtool-mar2022.exe"
    SHA512 32dd88e742211deaf0ca83e51ec510490456473c07fabbd6627960dc9abfa32289d99f2c8f53d7590a6a6733b3068ba25bff9a512fcf7d1072791dce931d463f
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont-mar2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool-mar2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool.exe")

elseif(NOT VCPKG_TARGET_IS_UWP)

  vcpkg_copy_tools(
        TOOL_NAMES XWBTool
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake"
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
