set(DIRECTXMESH_TAG apr2023)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXMesh
    REF ${DIRECTXMESH_TAG}
    SHA512 cd6608fafaa6d53c2f9ff9e7f316b0a79c8715e355d7362c83b08cae9a7add2561ce74e3350f41d71b1d2e99e61a3377e97073a562499a52677a22a87ba48f9b
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
    OPTIONS ${FEATURE_OPTIONS} -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxmesh)

if("tools" IN_LIST FEATURES)

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxmesh/")

  if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)

    vcpkg_download_distfile(
      MESHCONVERT_EXE
      URLS "https://github.com/Microsoft/DirectXMesh/releases/download/${DIRECTXMESH_TAG}/meshconvert.exe"
      FILENAME "meshconvert-${DIRECTXMESH_TAG}.exe"
      SHA512 afe3d2ee57d933740ab380d3577d10511b4ca7e33ddd6eafc9408fbbabe6295c676c6313916a9bdb94f1708a3565675e23212cc7f237e2007407c8948e934d86
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
      SHA512 a28bc4c3aced8ac59fee80cd734ef44127499ab14e7cd680276accd74dcea2dee382282889cb3f565a21d446bfc3b097f986d72b69e7a19b5a7d6e43252e5abc
    )

    file(INSTALL
      "${MESHCONVERT_EXE}"
      DESTINATION "${CURRENT_PACKAGES_DIR}/tools/directxmesh/")

    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/directxmesh/meshconvert-${DIRECTXMESH_TAG}-arm64.exe" "${CURRENT_PACKAGES_DIR}/tools/directxmesh/meshconvert.exe")

  else()

    vcpkg_copy_tools(
          TOOL_NAMES meshconvert
          SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake"
      )

  endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
