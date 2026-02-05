vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO efmsoft/logme
  REF v2.4.4
  SHA512 49e1e980d0c8079757d44e16e435dd8bea4c42f43c914d29d5f385e7bcd4068d461c1120b844bdc7c8cf6ced8fe9abc1ddef51f67f3cb04b1df46d2fbe71b40d
  HEAD_REF master
)

set(_logme_build_tools OFF)
if("tools" IN_LIST FEATURES)
  set(_logme_build_tools ON)
endif()

if(VCPKG_TARGET_IS_UWP AND _logme_build_tools)
  message(FATAL_ERROR "Feature 'tools' is not supported for UWP.")
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
    -DLOGME_BUILD_EXAMPLES=OFF
    -DLOGME_BUILD_TOOLS=${_logme_build_tools}
    -DUSE_JSONCPP=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/logme)

if(_logme_build_tools)
  # Upstream currently does not install the tool target.
  # Install the built binaries manually so vcpkg_copy_tools can pick them up.
  file(INSTALL
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/logmectl.exe"
    DESTINATION "${CURRENT_PACKAGES_DIR}/bin"
  )
  file(INSTALL
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/logmectl.exe"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin"
  )

  vcpkg_copy_tools(TOOL_NAMES logmectl AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
