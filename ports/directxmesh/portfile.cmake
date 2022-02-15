vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXMesh
    REF nov2021b
    SHA512 be2137c02c7a5973eaf91eaacfc9174148ec6dc68b163507d8146beb87c1ffff512e2593f7fd000ea7be440529ed2deda415e0dacd53e4c7d9679e97c6440d3d
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

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS} ${EXTRA_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(
    MESHCONVERT_EXE
    URLS "https://github.com/Microsoft/DirectXMesh/releases/download/nov2021/meshconvert.exe"
    FILENAME "meshconvert-nov2021.exe"
    SHA512 0f97ac49ce292b1cb90372884f1d6a4fc10eb3e92125a854ee9b7030fd9d0564536cdd88199aa4838832ae2a1e9c2df2c9e32c106705b6b06f156994b9476360
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxmesh/")

  file(INSTALL
    ${MESHCONVERT_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxmesh/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxmesh/meshconvert-nov2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxmesh/meshconvert.exe)

elseif((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))

  vcpkg_copy_tools(
        TOOL_NAMES meshconvert
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
