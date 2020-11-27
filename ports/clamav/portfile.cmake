vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO Cisco-Talos/clamav-devel
  REF clamav-0.103.0 
  SHA512 488381202bdcea812c39d611e0a31eaf8f55c9c5d0a6400fd53dfa0da674a95672fdc9b290dc6157cb8f628d9f81846b5cc108eb1e44f6207d3c6f2659ba63c6
  HEAD_REF master
  PATCHES
      "build.patch"
      "cmakefiles.patch"
      "curl.patch"
      "static_unrar.patch"
      "static_libclammspack.patch"
      "static_iconv.patch"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
      -DENABLE_LIBCLAMAV_ONLY=ON
      -DENABLE_DOCS=OFF
      -DENABLE_SHARED_LIB=${ENABLE_SHARED}
      -DENABLE_STATIC_LIB=${ENABLE_STATIC}
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# On Linux, clamav will still build and install clamav-config
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_copy_pdbs()
