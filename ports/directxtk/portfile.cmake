vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF jun2021
    SHA512 df15d20c3ab586e4f08b92a30d82f277e966aaa2555fa6161a6fb2308e65d79fdb3c65518f150fb08c31902d929aa01369dc8a852d2be31d30ecdf9253898fe0
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
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/jun2021/MakeSpriteFont.exe"
    FILENAME "makespritefont-jun2021.exe"
    SHA512 4618090f65332c64cb5601a7095c60c87a3a41e9c030d7422d36f14b04dcd80c7aa26438733b892f91daf19fadd44591a814b77c3ca04590ad6c61ecbe909a65
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/jun2021/XWBTool.exe"
    FILENAME "xwbtool-jun2021.exe"
    SHA512 dc74081b9569a9ca736984d8da1a5b2dc852f85d07a629d6e0ef7f2b4313987ec82d2ff1e0cfa19a89c7387182644869ac2a8f842d30609d88ccae7c01ce3f80
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtk/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont-jun2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool-jun2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool.exe)

elseif(NOT VCPKG_TARGET_IS_UWP)

  vcpkg_copy_tools(
        TOOL_NAMES XWBTool
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

  vcpkg_install_msbuild(
      SOURCE_PATH ${SOURCE_PATH}
      PROJECT_SUBPATH MakeSpriteFont/MakeSpriteFont.csproj
      PLATFORM AnyCPU
  )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
