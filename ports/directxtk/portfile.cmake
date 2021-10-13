vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF sept2021
    SHA512 57fb4cf54b09abee87ff2471c1b504b071a9d3229a09d01d5de58fa3e8bfc956262f21ace88cf05b13f4ff4184b2f7c3b018f9b95d0cac55825c4e3c6549ee89
    HEAD_REF master
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS} ${EXTRA_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(
    MAKESPRITEFONT_EXE
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/sept2021/MakeSpriteFont.exe"
    FILENAME "makespritefont-sept2021.exe"
    SHA512 a22ec8e7d283585574a5aec82c937c2844e89e66ded01fea92bb278beb7ff32c8070fa3016192029ed8c106db7ef0356f867521a2603a4de7c085cd8db693d0a
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/sept2021/XWBTool.exe"
    FILENAME "xwbtool-sept2021.exe"
    SHA512 40f33af95bfdaf60a41564dc347d51768774ad7caa8529046e3f87256e80e165aa124b21193d0ffa1e94644343006d6de01807df317dfdf13377a31275b973ef
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtk/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont-sept2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool-sept2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool.exe)

elseif(NOT VCPKG_TARGET_IS_UWP)

  vcpkg_copy_tools(
        TOOL_NAMES XWBTool
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
