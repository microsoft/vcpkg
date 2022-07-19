vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO intel/gpgmm
  REF v0.0.4
  SHA512 2ffc3c8299f2d10cb1c0013cd306ba45781a644fa0aa426ef1dfa616e4b53671461a376f65b7068b1ff8a4a2d1a6f9539664174eb5830ea6a760ef5e5d0fc6b0
  HEAD_REF main
)

# gpgmm\third_party config requires Git. Make the tool visible.
vcpkg_find_acquire_program(GIT)
get_filename_component(GIT_DIR "${GIT}" DIRECTORY)
vcpkg_add_to_path("${GIT_DIR}")

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  DISABLE_PARALLEL_CONFIGURE
  OPTIONS
  -DGPGMM_STANDALONE=OFF
  -DGPGMM_ENABLE_TESTS=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
