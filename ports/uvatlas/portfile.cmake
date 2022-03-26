vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/UVAtlas
    REF feb2022
    SHA512 20f9c38dd68edfca8179d26ab7f772b3190e843c01442ae3d7c7c1cd9a5a21a68455c124f0e8aab7efd3aacc9f6fb5907591b35a6a901683dad2a2f91d785106
    HEAD_REF main
)

if (VCPKG_HOST_IS_LINUX)
    message(WARNING "Build ${PORT} requires GCC version 9 or later")
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        eigen ENABLE_USE_EIGEN
)

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

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64) AND (NOT ("eigen" IN_LIST FEATURES)))
  vcpkg_download_distfile(
    UVATLASTOOL_EXE
    URLS "https://github.com/Microsoft/UVAtlas/releases/download/feb2022/uvatlastool.exe"
    FILENAME "uvatlastool-feb2022.exe"
    SHA512 bc7e00b67e9f7adda52882fdd6b0e54d3a34eb11164f189d5423efcbc7ee0dce5b2c0fbadce592e10917ab215f5d6c380bbc70597ac1001ea169364d563dff5f
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/uvatlas/")

  file(INSTALL
    ${UVATLASTOOL_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/uvatlas/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/uvatlas/uvatlastool-feb2022.exe ${CURRENT_PACKAGES_DIR}/tools/uvatlas/uvatlastool.exe)

elseif((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))

  vcpkg_copy_tools(
        TOOL_NAMES uvatlastool
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
