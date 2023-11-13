set(UVATLAS_TAG oct2023)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/UVAtlas
    REF ${UVATLAS_TAG}
    SHA512 2ad831663a0db907c21cc13af766704ff9b037a55032bed0e99e71aae496df367e00a7ee146b4f2223fa1390c4ad3f050a79dd6ffdbc0f16982dbb3592da8912
    HEAD_REF main
    PATCHES openexr.patch
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
      SHA512 66b773c97dc591785c7472557da7f9df0f682dd8b20a4751aa4e3ad97c3a0edc6080ce563ac49d21e3781a12ca0c748e1aa032b20839bcf06f6d21133e5cc8e1
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

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
