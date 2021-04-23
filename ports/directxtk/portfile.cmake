vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF apr2021
    SHA512 d64b5a6c39e9ecc4609a1db4c3121880b4e40431ec2e785aefff8e11615444485b0ffa68169cff6a5dda52f38bb2ce22161644e5fa4b757b9a84e682a458f846
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        xaudio2-9 BUILD_XAUDIO_WIN10
        xaudio2-8 BUILD_XAUDIO_WIN8
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
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/apr2021/MakeSpriteFont.exe"
    FILENAME "makespritefont-apr2021.exe"
    SHA512 f958dc0a88ff931182914ebb4b935d4ed71297d59a61fb70dbf7769d22350abc712acfdbbfbba658781600c83ac7e390eac0663ade747f749194addd209c5bfa
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/apr2021/XWBTool.exe"
    FILENAME "xwbtool-apr2021.exe"
    SHA512 8918fe7f5c996a54c6a5032115c9b82c6fe9b61688da3cde11c0282061c17a829639b219b8ff5ac623986507338c927eb926f2c42ba3c98563dfe7e162e22305
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtk/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont-apr2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool-apr2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool.exe)

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
