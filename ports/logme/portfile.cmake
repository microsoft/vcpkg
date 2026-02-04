vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO efmsoft/logme
  REF v2.4.3
  SHA512 343da7575848519861fa9f7c3987495d58fdd0d7fa2b22f77121230647bf233e98b743a6194a386c23479d940e4a88050d34447c77a730c8dcbacdf6f2b1727f
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
