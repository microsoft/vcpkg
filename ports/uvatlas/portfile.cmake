set(UVATLAS_TAG feb2024)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/UVAtlas
    REF ${UVATLAS_TAG}
    SHA512 893626920207e0d6707bdb579cb70f74e1abc8e31f00bfedb8fccb4f4034862068ba6174cc0824e4fb1d463c6c5bbcc9edbbdbfde654bc1fff7e075df2a2838d
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
      SHA512 14b606c57d0a1eeee573b5e484505d950534e6ab2d15693f5672fd52198de3b4986bddc48ee0957ee1936c7493c912212262c9c9ecdb91426ec74cd4f06d4d47
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
