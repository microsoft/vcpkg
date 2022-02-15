vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF nov2021b
    SHA512 d1c99cc7d1a95939b4dc28ee5c757e3b4eae2b7f923031b44f988b1ca93838e765d702f125a9a9fb38e6f5304721f88843e961b6ba9591066b511b530aad5280
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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS} ${EXTRA_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(
    MAKESPRITEFONT_EXE
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/nov2021/MakeSpriteFont.exe"
    FILENAME "makespritefont-nov2021.exe"
    SHA512 0aab40aced022588d9c1089c5b2f297b0521497d0ae559ead98f99e1e73f2daf9f38ebecadb413095abd2a6c207183fbca582d47528c6f21258df3ac391134e5
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/nov2021/XWBTool.exe"
    FILENAME "xwbtool-nov2021.exe"
    SHA512 f2f291c496500e593c0a4795fee9fafc685666682f23a38a25546bb67ec083533a26f2ce0562b819abea44bd8b403a2f246fbf978e366c457eb8a0f836fd5a2e
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont-nov2021.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool-nov2021.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool.exe")

elseif(NOT VCPKG_TARGET_IS_UWP)

  vcpkg_copy_tools(
        TOOL_NAMES XWBTool
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake"
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
