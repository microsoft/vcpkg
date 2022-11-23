set(UVATLAS_TAG oct2022)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/UVAtlas
    REF ${UVATLAS_TAG}
    SHA512 d6c6428ee7d19888cf5b50bff328fa55dec13a8e660f65eab4e4a4538cbf57282d75fbfd079880fa322522d5fd5db10dcb42d62c1b57f76cf04f0843d4b52705
    HEAD_REF main
    PATCHES
        openexr.patch
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
vcpkg_cmake_config_fixup(CONFIG_PATH share/uvatlas)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64) AND (NOT ("eigen" IN_LIST FEATURES)))
  vcpkg_download_distfile(
    UVATLASTOOL_EXE
    URLS "https://github.com/Microsoft/UVAtlas/releases/download/${UVATLAS_TAG}/uvatlastool.exe"
    FILENAME "uvatlastool-${UVATLAS_TAG}.exe"
    SHA512 7ee673db394a83762d6227faa9e643fafeb2ef3e1be1fdfff363f04f3e5d826ff2d314530f6372357fac8a01d284e6861cc3a88ce81f3bd7baa71303d68e3c86
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/uvatlas/")

  file(INSTALL
    ${UVATLASTOOL_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/uvatlas/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/uvatlas/uvatlastool-${UVATLAS_TAG}.exe ${CURRENT_PACKAGES_DIR}/tools/uvatlas/uvatlastool.exe)

elseif((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))

  vcpkg_copy_tools(
        TOOL_NAMES uvatlastool
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
