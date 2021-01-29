vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXMesh
    REF jan2021b
    SHA512 dab353d5033c32cf5667b95820cf3048e4773fa3fed16d24b25a515fbf4b6f6792ab5955dc9bb790c911b4cae1af1166aa0fdc4f5a639b3f4c3c81a2451a9a40
    HEAD_REF master
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS} ${EXTRA_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

if((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))
  vcpkg_copy_tools(
        TOOL_NAMES meshconvert
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

elseif((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(
    MESHCONVERT_EXE
    URLS "https://github.com/Microsoft/DirectXMesh/releases/download/jan2021/meshconvert.exe"
    FILENAME "meshconvert-jan2021.exe"
    SHA512 7df51baa495859aab418d194fd885cf37945ec2927122c18718b3a1a7d7ceb08c6853d084d74bf2bf2bc9ace47a351fd6b8d03706507f4966111ec1cb83f43a2
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxmesh/")

  file(INSTALL
    ${MESHCONVERT_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxmesh/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxmesh/meshconvert-jan2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxmesh/meshconvert.exe)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
