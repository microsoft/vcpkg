if (EXISTS "${CURRENT_INSTALLED_DIR}/share/openexr")
  message(FATAL_ERROR "openexr 2 is installed, please uninstall and try again:\n    vcpkg remove openexr")
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO openexr/openexr
  REF v3.1.5
  SHA512 01ef16eacd2dde83c67b81522bae87f47ba272a41ce7d4e35d865dbdcaa03093e7ac504b95d2c1b3a19535f2364a4f937b0e0570c74243bb1c6e021fce7b620c
  HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
    -DCMAKE_DEBUG_POSTFIX=_d
    -DBUILD_TESTING:BOOL=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OpenEXR/)

vcpkg_copy_pdbs()

set(OPENEXR_TOOLS exr2aces  exrenvmap  exrheader  exrinfo  exrmakepreview  exrmaketiled  exrmultipart  exrmultiview  exrstdattr)
vcpkg_copy_tools(TOOL_NAMES ${OPENEXR_TOOLS} AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)