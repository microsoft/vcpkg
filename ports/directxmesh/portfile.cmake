set(DIRECTXMESH_TAG feb2024)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXMesh
    REF ${DIRECTXMESH_TAG}
    SHA512 f15bba68982ffb69f2f07503aeb565a95b733feb14b5bfb546284e6be498e6e45a286e556228c4284c8fccddd3581cc7aa10b5b522f9ba4d511f0303757c83e8
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dx12 BUILD_DX12
        spectre ENABLE_SPECTRE_MITIGATION
        tools BUILD_TOOLS
)

if (VCPKG_HOST_IS_LINUX)
    message(WARNING "Build ${PORT} requires GCC version 9 or later")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxmesh)

if("tools" IN_LIST FEATURES)

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxmesh/")

  if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)

    vcpkg_download_distfile(
      MESHCONVERT_EXE
      URLS "https://github.com/Microsoft/DirectXMesh/releases/download/${DIRECTXMESH_TAG}/meshconvert.exe"
      FILENAME "meshconvert-${DIRECTXMESH_TAG}.exe"
      SHA512 a1a7187a19b5947dd5ab34097da55793f43fccb0cd1efc81d9b8ccdd8fcffeb638174c004c64a4cf9b720e878d9352fa3c2a7a1082de7123279dde14cc5a628c
    )

    file(INSTALL
      "${MESHCONVERT_EXE}"
      DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxmesh/")

    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxmesh/meshconvert-${DIRECTXMESH_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/directxmesh/meshconvert.exe")

  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL arm64)

    vcpkg_download_distfile(
      MESHCONVERT_EXE
      URLS "https://github.com/Microsoft/DirectXMesh/releases/download/${DIRECTXMESH_TAG}/meshconvert_arm64.exe"
      FILENAME "meshconvert-${DIRECTXMESH_TAG}-arm64.exe"
      SHA512 77e844accd195c859ca9501575e8aa83b2dda21efd0a313f46362321be0384c24bf8f16e45cfc543162488f4af18220260dc7155c8b49a0737cecc31fd152b2b
    )

    file(INSTALL
      "${MESHCONVERT_EXE}"
      DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxmesh/")

    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxmesh/meshconvert-${DIRECTXMESH_TAG}-arm64.exe" "${CURRENT_PACKAGES_DIR}/tools/directxmesh/meshconvert.exe")

  else()

    vcpkg_copy_tools(
          TOOL_NAMES meshconvert
          SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin"
      )

  endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
