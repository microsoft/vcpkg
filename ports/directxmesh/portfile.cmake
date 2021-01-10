vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXMesh
    REF nov2020b
    SHA512 a3520d916324e16004ec0052c6d4c628be2ea62583d0169b663f67ce03ef84c3ba8ea01c239c75dc89a359de6748039dc11e405ba4b0c4f33ee0225e4e248415
    HEAD_REF master
    FILE_DISAMBIGUATOR 2
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dx12 BUILD_DX12
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
        TOOL_NAMES meshconvert
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

elseif((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(meshconvert
    URLS "https://github.com/Microsoft/DirectXMesh/releases/download/nov2020/meshconvert.exe"
    FILENAME "meshconvert.exe"
    SHA512 189552c74dc634f673a0d15851d7bb7c42c860023b1488086a9904323fc45207244c159c8848a211afafe258825f5051ee6fd85080da3f7f4afdf910764ca8ec
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxmesh/")

  file(INSTALL
    ${DOWNLOADS}/meshconvert.exe
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxmesh/)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
