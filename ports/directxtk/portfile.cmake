vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF jan2021b
    SHA512 87cac6f3ea9e16b5b2d195fd363d5da45d99a08b4bb7be8261a7347ec0e316604acc130129cabc24d635be77ec2487341eca1c5f46238d3ce27fbde1a2e817d1
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

if(NOT VCPKG_TARGET_IS_UWP)
  vcpkg_copy_tools(
        TOOL_NAMES XWBTool
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

  vcpkg_install_msbuild(
      SOURCE_PATH ${SOURCE_PATH}
      PROJECT_SUBPATH MakeSpriteFont/MakeSpriteFont.csproj
      PLATFORM AnyCPU
  )

elseif((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(
    MAKESPRITEFONT_EXE
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/jan2021/MakeSpriteFont.exe"
    FILENAME "makespritefont-jan2021.exe"
    SHA512 0cca19694fd3625c5130a85456f7bf1dabc8c5f893223c19da134a0c4d64de853f7871644365dcec86012543f3a59a96bfabd9e51947648f6d82480602116fc4
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/jan2021/XWBTool.exe"
    FILENAME "xwbtool-jan2021.exe"
    SHA512 91c9d0da90697ba3e0ebe4afcc4c8e084045b76b26e94d7acd4fd87e5965b52dd61d26038f5eb749a3f6de07940bf6e3af8e9f19d820bf904fbdb2752b78fce9
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtk/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont-jan2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool-jan2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool.exe)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
