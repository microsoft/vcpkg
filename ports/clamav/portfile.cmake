vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO Cisco-Talos/clamav-devel
  REF clamav-0.103.0
  SHA512 e7ff4d98e0615a9fec0752bbfa2b882ae95034a8e01d0f7cc635ee520ff917c3be2a2d3273caa2fc1598e7d5ec4fd60d59b517cb439c5454d32447f8c8d7ba5a
  FILE_DISAMBIGUATOR 1
  HEAD_REF master
  PATCHES
      "build.patch"
      "cmakefiles.patch"
      "curl.patch"
      "mspack.patch"
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
