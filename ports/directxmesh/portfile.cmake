set(DIRECTXMESH_TAG oct2022)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXMesh
    REF ${DIRECTXMESH_TAG}
    SHA512 05bc2460a35ecb13c766d2e66546cfc5b589f22a60ce236730ce865eba2fe57caffae6b730bad2491c9c89bc3472e5f7437d197c8bb9f9f80a055707681943a1
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dx12 BUILD_DX12
)

if (VCPKG_HOST_IS_LINUX)
    message(WARNING "Build ${PORT} requires GCC version 9 or later")
endif()

if(VCPKG_TARGET_IS_UWP)
  set(EXTRA_OPTIONS -DBUILD_TOOLS=OFF)
else()
  set(EXTRA_OPTIONS -DBUILD_TOOLS=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS} ${EXTRA_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxmesh)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(
    MESHCONVERT_EXE
    URLS "https://github.com/Microsoft/DirectXMesh/releases/download/${DIRECTXMESH_TAG}/meshconvert.exe"
    FILENAME "meshconvert-${DIRECTXMESH_TAG}.exe"
    SHA512 471f39dffca6b2fcfb439e94c9fbec3721bf8792635cdf67a0ec3e136445d83dc9d0abdfa3908b2f2aea969fb69e8bc8391eababc92305060a04a577e960a591
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxmesh/")

  file(INSTALL
    ${MESHCONVERT_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxmesh/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxmesh/meshconvert-${DIRECTXMESH_TAG}.exe ${CURRENT_PACKAGES_DIR}/tools/directxmesh/meshconvert.exe)

elseif((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))

  vcpkg_copy_tools(
        TOOL_NAMES meshconvert
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
