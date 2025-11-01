set(UVATLAS_TAG jul2025)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/UVAtlas
    REF ${UVATLAS_TAG}
    SHA512 cdc1f5116e63ed807c808e51ec78b00a3b04634d63b00980e75ca3886d59b5f7dd02bd8ba6caad89890dd9cc769603ba3587f6009479f186297ad4f4d259b221
    HEAD_REF main
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
    OPTIONS ${FEATURE_OPTIONS}
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
      SHA512 fa9453467c958328186a82552b5d0dd946b27cac16c86cd6f81d2ef35a750f37510d8519cc7cdeabb126e2a30886635157029f85c0cda731243bdeb51d3775d9
    )

    file(INSTALL
      "${UVATLASTOOL_EXE}"
      DESTINATION "${CURRENT_PACKAGES_DIR}/tools/uvatlas/")

    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/uvatlas/uvatlastool-${UVATLAS_TAG}.exe" "${CURRENT_PACKAGES_DIR}/tools/uvatlas/uvatlastool.exe")

  else()

    vcpkg_copy_tools(
          TOOL_NAMES uvatlastool
          SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin"
      )

  endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
