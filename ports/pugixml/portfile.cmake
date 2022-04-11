vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeux/pugixml
    REF v1.12.1
    SHA512 c1a80518e8d7b21f2a15b2023b77e87484f5b7581e68ff508785a60cab53d1689b5508f5a652d6f0d4fbcc91f66d59246fdfe499fd6b0e188c7914ed5919980b
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    wchar-mode	PUGIXML_WCHAR_MODE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
      -DPUGIXML_USE_POSTFIX=ON
      ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/pugixml)
vcpkg_fixup_pkgconfig()

if ("wchar-mode" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/pugiconfig.hpp" "// #define PUGIXML_WCHAR_MODE" "#define PUGIXML_WCHAR_MODE")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/readme.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
