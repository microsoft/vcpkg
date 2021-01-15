vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF jan2021
    SHA512 c0e8df3ef3a276169c219798978eb948947ba63f49fd08be914eee87ed4bb05a4e33e3a4d1c06c4e932f5ad8fa50a14e0b53a9b9f6f749aa15174f343a17555c
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
  vcpkg_download_distfile(makespritefont
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/jan2021/MakeSpriteFont.exe"
    FILENAME "makespritefont.exe"
    SHA512 0cca19694fd3625c5130a85456f7bf1dabc8c5f893223c19da134a0c4d64de853f7871644365dcec86012543f3a59a96bfabd9e51947648f6d82480602116fc4
  )

  vcpkg_download_distfile(xwbtool
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/jan2021/XWBTool.exe"
    FILENAME "xwbtool.exe"
    SHA512 91c9d0da90697ba3e0ebe4afcc4c8e084045b76b26e94d7acd4fd87e5965b52dd61d26038f5eb749a3f6de07940bf6e3af8e9f19d820bf904fbdb2752b78fce9
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

  file(INSTALL
    ${DOWNLOADS}/makespritefont.exe
    ${DOWNLOADS}/xwbtool.exe
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtk/)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
