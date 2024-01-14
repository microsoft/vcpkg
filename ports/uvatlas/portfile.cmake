set(UVATLAS_TAG dec2023)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/UVAtlas
    REF ${UVATLAS_TAG}
    SHA512 44caebdb6c4c2fc42c8dbbe4acbaf7046996dfcd08e36d622c50a024c1ea3968e1174bd4bf35356068d163c76ac88b697bebb4904dcd2c2bdb6e3e2daf9781d3
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

set(EXTRA_OPTIONS -DBUILD_TESTING=OFF)

if (VCPKG_HOST_IS_LINUX)
    message(WARNING "Build ${PORT} requires GCC version 9 or later")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS} ${EXTRA_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH share/uvatlas)

if("tools" IN_LIST FEATURES)

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/uvatlas/")

  if((VCPKG_TARGET_ARCHITECTURE STREQUAL x64) AND (NOT ("eigen" IN_LIST FEATURES)))

    vcpkg_download_distfile(
      UVATLASTOOL_EXE
      URLS "https://github.com/Microsoft/UVAtlas/releases/download/${UVATLAS_TAG}/uvatlastool.exe"
      FILENAME "uvatlastool-${UVATLAS_TAG}.exe"
      SHA512 d8c76c4745e120f45e99330be09498e53d013d64342c7df836a9d3bc6746cfc1d0d351b9d7d8ae76c24206f3032d98a4402a04b8a6450d2ced68594675f9be08
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
