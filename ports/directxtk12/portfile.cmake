vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF nov2020b
    SHA512 3a47209f109f993e4ca779bca9c9417c3f11a0472b3c91f52beb46a388edc5487d4e2cd472371ef6ffc4d3e54782d12e884befe8537fa68190c1556d6e36fbab
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_XAUDIO_WIN10=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(makespritefont
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/nov2020/MakeSpriteFont.exe"
    FILENAME "makespritefont.exe"
    SHA512 d576eecd9763d238e12ba8d865917738a4bc8cbf632943e5c11b9426ecdfeaa9e8522076f1bb7122d41e69158fc7ca0939f2d90f9986470639966b3f849d236a
  )

  vcpkg_download_distfile(xwbtool
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/nov2020/XWBTool.exe"
    FILENAME "xwbtool.exe"
    SHA512 6ac8fc12fcea0f808aac1367907dbbb0c5669c8c654fc21f38b4e1ce951710ade1851515dba074e9254579b018545c3cdb2b6cf57366dfba0196603510bf51cd
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(INSTALL
    ${DOWNLOADS}/makespritefont.exe
    ${DOWNLOADS}/xwbtool.exe
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtk12/)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
