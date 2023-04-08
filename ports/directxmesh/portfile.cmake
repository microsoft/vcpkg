set(DIRECTXMESH_TAG mar2023)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXMesh
    REF ${DIRECTXMESH_TAG}
    SHA512 a017f022945a078a27c19815100f466714b9cbdad067dfa36b8e457ec78b8febcb7661dee55e3d7ee41461325f0af9c442c04c0e8e406c268062ce96b46b7af8
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
      SHA512 bb7ab1014f99f3c2a9c0b6b22333fa2aaeed952fa1fe0f675a5b53cf227385e6492a73dc34f0df9a80f0cde2ba3353d0ceca2520c3ca8efb61e2dcbe42065d40
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
      SHA512 401a132d6c70dd07c1377cbef3bce53cb27bfa48344409cbb4ace9f266f17ea3221ea43f45f0e502f6a26608e108251eda89900dd2ae88eb3894ac54176d152a
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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
