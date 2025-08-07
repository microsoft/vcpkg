vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO Cisco-Talos/clamav-devel
  REF clamav-0.103.11
  SHA512 2d614b5006fe526d7bb43dfc691329f2de2fa2dc6cfc63fb93ba556ee26a9f87369bf072f59db0fed178c44413d68838b45ea572885c8d0a0bee81a410d5e055
  FILE_DISAMBIGUATOR 1
  HEAD_REF master
  PATCHES
      "build.patch"
      "cmakefiles.patch"
      "curl.patch"
      "mspack.patch"
      "isnt.patch"
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
      -DENABLE_LIBCLAMAV_ONLY=ON
      -DENABLE_DOCS=OFF
      -DENABLE_SHARED_LIB=ON
      -DENABLE_STATIC_LIB=OFF
      -DENABLE_EXTERNAL_MSPACK=ON
)

vcpkg_cmake_install()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# On Linux, clamav will still build and install clamav-config
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_copy_pdbs()
