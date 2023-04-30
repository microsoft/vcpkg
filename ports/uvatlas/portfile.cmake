set(UVATLAS_TAG apr2023)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/UVAtlas
    REF ${UVATLAS_TAG}
    SHA512 3836ccde6d43482c70a2c1909edf8034e04316d0e4afaeb137cd5cfc377345213d5c159688f9d0adf306030f4f9d9d83ce754026e3dc656c363bfb9d21a80dc3
    HEAD_REF main
    PATCHES
    openexr.patch
    0001-Update-CMake-to-use-OpenMP-via-built-in-support.patch
    0002-Clang-fix-for-error-break-statement-used-with-OpenMP.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        eigen ENABLE_USE_EIGEN
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
vcpkg_cmake_config_fixup(CONFIG_PATH share/uvatlas)

if("tools" IN_LIST FEATURES)

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/uvatlas/")

  if((VCPKG_TARGET_ARCHITECTURE STREQUAL x64) AND (NOT ("eigen" IN_LIST FEATURES)))

    vcpkg_download_distfile(
      UVATLASTOOL_EXE
      URLS "https://github.com/Microsoft/UVAtlas/releases/download/${UVATLAS_TAG}/uvatlastool.exe"
      FILENAME "uvatlastool-${UVATLAS_TAG}.exe"
      SHA512 9009113286a28c19102c8fa4d8768f9d81ad563cc5698ba50ac8cb483b0e5734f1d86d6e398cabb1cf1f3801ec0dc567a78c2d91ee8d7c8d81bd1ef610be0a0c
    )

    file(INSTALL
      "${UVATLASTOOL_EXE}"
      DESTINATION "${CURRENT_PACKAGES_DIR}/tools/uvatlas/")

    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/uvatlas/uvatlastool-${UVATLAS_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/uvatlas/uvatlastool.exe")

  else()

    vcpkg_copy_tools(
          TOOL_NAMES uvatlastool
          SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake"
      )

  endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
