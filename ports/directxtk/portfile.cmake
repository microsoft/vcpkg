set(DIRECTXTK_TAG oct2022)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_TARGET_IS_MINGW)
    message(NOTICE "Building ${PORT} for MinGW requires the HLSL Compiler fxc.exe also be in the PATH. See https://aka.ms/windowssdk.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF ${DIRECTXTK_TAG}
    SHA512 59cdfb0e7c3ca121ffc4935f93702b67b66dc000920de915b1589b74a192b015aa46e42438f6a2e68da344001ec69896691cf343eae3379cec272feeeb2ee02c
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
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/${DIRECTXTK_TAG}/MakeSpriteFont.exe"
    FILENAME "makespritefont-${DIRECTXTK_TAG}.exe"
    SHA512 1a55c1fe22f10c883fad4c263437a5d5084275f4303863afc7c1cc871221364d189963f248b7b338f002fac1ae7fda40352a7ef6c96bfdc1ffded2f53c187c32
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK/releases/download/${DIRECTXTK_TAG}/XWBTool.exe"
    FILENAME "xwbtool-${DIRECTXTK_TAG}.exe"
    SHA512 ab14800b36a7e40785c0e8b88e08e3d6e0ab8f25711093633ce66e0c123cb5eef72ac7e6a3ce714ad6b6881d54c04149ba64101f768b5dd40c48f52b41514abc
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont-${DIRECTXTK_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk/makespritefont.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool-${DIRECTXTK_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk/xwbtool.exe")

elseif(NOT VCPKG_TARGET_IS_UWP)

  vcpkg_copy_tools(
        TOOL_NAMES XWBTool
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake"
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
