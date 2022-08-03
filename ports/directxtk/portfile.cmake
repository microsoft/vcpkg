vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_TARGET_IS_MINGW)
    message(NOTICE "Building ${PORT} for MinGW requires the HLSL Compiler fxc.exe also be in the PATH. See https://aka.ms/windowssdk.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF jul2022
    SHA512 1f16d682e2ed7d177ec7ab0f5ecbcfd11f85478eff52db781403c6c1dca8945521da3a5fd926ea46a4d319c94bc0f21eacea7b456da4283ccac21614e3338f58
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
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxtk)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(
    MAKESPRITEFONT_EXE
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/jul2022/MakeSpriteFont.exe"
    FILENAME "makespritefont-jul2022.exe"
    SHA512 fd039070fad3dee3fe146d2cd4950f599f680cb4abd370e7c21bedeb8c0a970455ad2eac463fc6d198505b6bbdabebfcc453bf74c317f6a10bf2e2f9a0bfc418
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/jul2022/XWBTool.exe"
    FILENAME "xwbtool-jul2022.exe"
    SHA512 6276e17241afc8c0b82789b99667577394eedf001fa2d4b3acdfac847744c3ac5ec9a8072a1e3e9f247386711232aab93f066a0689f4f9f7d84744dc3862ea05
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont-jul2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool-jul2022.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool.exe")

elseif(NOT VCPKG_TARGET_IS_UWP)

  vcpkg_copy_tools(
        TOOL_NAMES XWBTool
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake"
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
