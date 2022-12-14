set(DIRECTXTK_TAG oct2022)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF ${DIRECTXTK_TAG}
    SHA512 f9117e3e2119cf54dd003efa04a3a803558c4326a884c604ff3502e488b40e4372d226d3070d509b8e462fdddd3b23fae3b3aebd1ebfa74d99e01b2f4bfac312
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        xaudio2-9 BUILD_XAUDIO_WIN10
        xaudio2redist BUILD_XAUDIO_REDIST
)

set(DXCPATH ${CURRENT_HOST_INSTALLED_DIR}/tools/directx-dxc)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS} -DBUILD_DXIL_SHADERS=ON -DDIRECTX_DXC_PATH=${DXCPATH}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxtk12)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(
    MAKESPRITEFONT_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/${DIRECTXTK_TAG}/MakeSpriteFont.exe"
    FILENAME "makespritefont-${DIRECTXTK_TAG}.exe"
    SHA512 1a55c1fe22f10c883fad4c263437a5d5084275f4303863afc7c1cc871221364d189963f248b7b338f002fac1ae7fda40352a7ef6c96bfdc1ffded2f53c187c32
  )

  vcpkg_download_distfile(
    XWBTOOL_EXE
    URLS "https://github.com/Microsoft/DirectXTK12/releases/download/${DIRECTXTK_TAG}/XWBTool.exe"
    FILENAME "xwbtool-${DIRECTXTK_TAG}.exe"
    SHA512 ab14800b36a7e40785c0e8b88e08e3d6e0ab8f25711093633ce66e0c123cb5eef72ac7e6a3ce714ad6b6881d54c04149ba64101f768b5dd40c48f52b41514abc
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(INSTALL
    ${MAKESPRITEFONT_EXE}
    ${XWBTOOL_EXE}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxtk12/")

  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont-${DIRECTXTK_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/makespritefont.exe")
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool-${DIRECTXTK_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxtk12/xwbtool.exe")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
