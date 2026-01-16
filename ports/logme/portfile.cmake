vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO efmsoft/logme
  REF v2.4.1
  SHA512 5a2e761c855a66fbec82235e47ec921ca0021f046447cc7cdb876a548786729e7695d6201843ba0359a5fea78de3261edf3d068ba85d1875600096adfcc05811
  HEAD_REF master
)

vcpkg_check_features(
  OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    examples LOGME_BUILD_EXAMPLES
    tools    LOGME_BUILD_TOOLS
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  set(_logme_static_opt  ON)
  set(_logme_dynamic_opt OFF)
else()
  set(_logme_static_opt  OFF)
  set(_logme_dynamic_opt ON)
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLOGME_BUILD_STATIC=${_logme_static_opt}
    -DLOGME_BUILD_DYNAMIC=${_logme_dynamic_opt}
    -DLOGME_BUILD_TESTS=OFF
    -DUSE_JSONCPP=ON
    ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
  PACKAGE_NAME logme
  CONFIG_PATH lib/cmake/logme
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
