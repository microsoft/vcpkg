vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF aug2021
    SHA512 ed4ff5c8a1f12e2489a4ddb653a0d8097da4a901498852ada5595959f6e6275531e11ca20d8ce16da19f3ac37193b23edf7c9c1b6d6a78a8810e8f0d399ca4b8
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
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/aug2021/MakeSpriteFont.exe"
    FILENAME "makespritefont-aug2021.exe"
    SHA512 a84786f57f7f26c4ab0cd446136d79c19a74296f5074396854c81ad67aedfccfe76e15025ba9bcfcabb993f0bb7247ca536d55b4574192efb3e7c2069abf70d7
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/aug2021/XWBTool.exe"
    FILENAME "xwbtool-aug2021.exe"
    SHA512 3dd1ebd04db21517f74453727512783141b997d33efc1a47236c9ff343310da17b4add4c4ba6e138ad35095fb77f4207e7458a9e51ee3f4872fc0e0cf62be5b5
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtk/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont-aug2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool-aug2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool.exe)

elseif(NOT VCPKG_TARGET_IS_UWP)

  vcpkg_copy_tools(
        TOOL_NAMES XWBTool
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
