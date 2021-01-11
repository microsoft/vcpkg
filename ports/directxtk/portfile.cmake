vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF nov2020b
    SHA512 25c8404a949988bcb468383bffa9510dfcc4fa5498f10319816024448987bbddbecef4a29c44d414d5696b0ec58704fd10071b674fc24ec5844fc5bf0f58097e
    HEAD_REF master
    FILE_DISAMBIGUATOR 2
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
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/nov2020/MakeSpriteFont.exe"
    FILENAME "makespritefont.exe"
    SHA512 d576eecd9763d238e12ba8d865917738a4bc8cbf632943e5c11b9426ecdfeaa9e8522076f1bb7122d41e69158fc7ca0939f2d90f9986470639966b3f849d236a
  )

  vcpkg_download_distfile(xwbtool
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/nov2020/XWBTool.exe"
    FILENAME "xwbtool.exe"
    SHA512 6ac8fc12fcea0f808aac1367907dbbb0c5669c8c654fc21f38b4e1ce951710ade1851515dba074e9254579b018545c3cdb2b6cf57366dfba0196603510bf51cd
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

  file(INSTALL
    ${DOWNLOADS}/makespritefont.exe
    ${DOWNLOADS}/xwbtool.exe
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtk/)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
