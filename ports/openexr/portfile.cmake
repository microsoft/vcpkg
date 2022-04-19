vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO AcademySoftwareFoundation/openexr
  REF 420da6a57a3ecaeab481b993dd590eeec8fe0c52 # v3.1.5
  SHA512 5d8a5b0111394385aaacbdc6225c7ce75fa4e0126555b77a290ea51cabbe92d7c9ad41ebdddc779e9018651262e4777d3a07166d862feefc57ac8bd3460dc76a
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DPYILMBASE_ENABLE=FALSE
    -DOPENEXR_INSTALL_EXAMPLES=OFF
    -DBUILD_TESTING=OFF
  OPTIONS_DEBUG
    -DOPENEXR_INSTALL_TOOLS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES exr2aces exrenvmap exrheader exrinfo exrmakepreview
  exrmaketiled exrmultipart exrmultiview exrstdattr AUTO_CLEAN
)

vcpkg_copy_pdbs()

if (VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
