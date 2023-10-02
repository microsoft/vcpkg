vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/cpptrace
    REF "v${VERSION}"
    SHA512 75a91d29868d366df860412eeee34546cb4b9fdc448b330e695643593483fdd2ae4f959efb7bac8c7f832e2cc21f5423f907663231f9517ecf11155339498752
    HEAD_REF main
    PATCHES v0.2.0-patches.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  vcpkg_cmake_configure(
      SOURCE_PATH "${SOURCE_PATH}"
      OPTIONS -DCPPTRACE_STATIC=On
  )
else()
  vcpkg_cmake_configure(
      SOURCE_PATH "${SOURCE_PATH}"
  )
endif()

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "cpptrace"
    CONFIG_PATH "lib/cmake/cpptrace"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

if(WIN32 AND NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
  file(RENAME "${CURRENT_PACKAGES_DIR}/lib/cpptrace.dll" "${CURRENT_PACKAGES_DIR}/bin/cpptrace.dll")
  file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/cpptrace.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/cpptrace.dll")
endif()
