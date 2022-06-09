vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXMesh
    REF may2022
    SHA512 f82ac5bf8211cb5699caf79cf2fb13eb23b4c3c8de807bc114966cc8e933b3bdb2c98940c9add74ee9ad0addb1bdf91dd16cbe2efe2db2afd96f69fd3871d556
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
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxmesh/cmake)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(
    MESHCONVERT_EXE
    URLS "https://github.com/Microsoft/DirectXMesh/releases/download/may2022/meshconvert.exe"
    FILENAME "meshconvert-may2022.exe"
    SHA512 0fcc3728425bc9681bdc4e1fae79a0f3da638d1b43597171e6829fca85cec8e7f1aa30a51c2f9457074c0a7bb9f358da06df666b6ae054266ceb1c9c38874547
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxmesh/")

  file(INSTALL
    ${MESHCONVERT_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxmesh/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxmesh/meshconvert-may2022.exe ${CURRENT_PACKAGES_DIR}/tools/directxmesh/meshconvert.exe)

elseif((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))

  vcpkg_copy_tools(
        TOOL_NAMES meshconvert
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
