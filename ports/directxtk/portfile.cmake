vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF nov2020b
    SHA512 43a8d3ffdf975f80c082eee6669cac8208fb0382f1f3cd74e6520f953ca9c667b54c7828821680d93ce4f14778edd6e75bb3f1f3a69839d6bfb704c6fbc8a8d3
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        xaudio2-9 BUILD_XAUDIO_WIN10
        xaudio2-8 BUILD_XAUDIO_WIN8
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS} -DBUILD_TOOLS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

if(VCPKG_HOST_IS_WINDOWS)
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
