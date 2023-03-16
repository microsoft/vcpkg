set(UVATLAS_TAG feb2023)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/UVAtlas
    REF feb2023b
    SHA512 4780c6a7f33b7d659e8dd39f48d6adefd22b1a4ed4ff41a1f74614f05048dfed643235d13064a84bd6839642baf9eb7f55f0a8d68db0fb655b7652a7e914fde8
    HEAD_REF main
    PATCHES openexr.patch
)

if (VCPKG_HOST_IS_LINUX)
    message(WARNING "Build ${PORT} requires GCC version 9 or later")
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        eigen ENABLE_USE_EIGEN
        spectre ENABLE_SPECTRE_MITIGATION
)

set(EXTRA_OPTIONS -DBUILD_TESTING=OFF)

if(VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_XBOX)
  list(APPEND EXTRA_OPTIONS -DBUILD_TOOLS=OFF)
else()
  list(APPEND EXTRA_OPTIONS -DBUILD_TOOLS=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS} ${EXTRA_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/uvatlas)

if(VCPKG_HOST_IS_WINDOWS AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64) AND (NOT ("eigen" IN_LIST FEATURES)))
  vcpkg_download_distfile(
    UVATLASTOOL_EXE
    URLS "https://github.com/Microsoft/UVAtlas/releases/download/${UVATLAS_TAG}/uvatlastool.exe"
    FILENAME "uvatlastool-${UVATLAS_TAG}.exe"
    SHA512 f34aa4ec7e10bbe24eefe31ddb98841fa097385921d8c3d813e30836749c4b9f4b6e792c371f59c55e446e91845dbd9d333332f6c06cd8cd966cd2bfee89e29e
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/uvatlas/")

  file(INSTALL
    ${UVATLASTOOL_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/uvatlas/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/uvatlas/uvatlastool-${UVATLAS_TAG}.exe ${CURRENT_PACKAGES_DIR}/tools/uvatlas/uvatlastool.exe)

elseif(VCPKG_TARGET_IS_WINDOWS AND (NOT VCPKG_TARGET_IS_UWP) AND (NOT VCPKG_TARGET_IS_XBOX))

  vcpkg_copy_tools(
        TOOL_NAMES uvatlastool
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
