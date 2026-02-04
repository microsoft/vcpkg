vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO efmsoft/logme
  REF v2.4.4
  SHA512 49e1e980d0c8079757d44e16e435dd8bea4c42f43c914d29d5f385e7bcd4068d461c1120b844bdc7c8cf6ced8fe9abc1ddef51f67f3cb04b1df46d2fbe71b40d
  HEAD_REF master
)

vcpkg_check_features(
  OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    examples LOGME_BUILD_EXAMPLES
    tools    LOGME_BUILD_TOOLS
)

if(VCPKG_TARGET_IS_UWP)
  list(APPEND FEATURE_OPTIONS
    -DLOGME_BUILD_EXAMPLES=OFF
    -DLOGME_BUILD_TOOLS=OFF
  )
endif()

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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
