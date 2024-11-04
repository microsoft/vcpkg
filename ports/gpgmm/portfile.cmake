vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO intel/gpgmm
  REF "v${VERSION}"
  SHA512 1e949e87110e555aa139e564a667a030150e77fd9b174f11bd3238b1fc3e7ae7ef17cc483b8afc9b0b7c346ce36564c94959454e27509c520bec18ef8396b5a1
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  DISABLE_PARALLEL_CONFIGURE
  OPTIONS
      -DGPGMM_STANDALONE=OFF
      -DGPGMM_ENABLE_TESTS=OFF
      -DGPGMM_ENABLE_VK=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(GLOB_RECURSE GPGMM_INCLUDE "${SOURCE_PATH}/include/*.h")
file(INSTALL ${GPGMM_INCLUDE} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
