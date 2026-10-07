vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    tools BETACALENDARS_BUILD_TOOLS
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mateopedersen/betacalendars-calendar-layout
  REF v0.1.0
  SHA512 56d93f3efdbe7909d9963329bd60245b5f47ddf93f14260691983b4913ccb10745362300b44809ae575ca48a9cd175fa81a04c358f58826a8d51c1d7b2da9fc1
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME BetaCalendarsCalendarLayout CONFIG_PATH lib/cmake/BetaCalendarsCalendarLayout)

if("tools" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES betacal-layout AUTO_CLEAN)
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# This package is header-only. The config helper has moved its CMake package
# files to share; discard duplicate debug headers, license files, and empty lib dirs.
file(REMOVE_RECURSE
  "${CURRENT_PACKAGES_DIR}/debug"
  "${CURRENT_PACKAGES_DIR}/lib"
  "${CURRENT_PACKAGES_DIR}/share/licenses"
)
