if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ArtifexSoftware/mujs
  REF "${VERSION}"
  SHA512 52954ec5a8a7ca91c818936c24b7fb757bfb14e75f2311a5550b76838c8a6caf6d8c18dc599e77fc5b774b1ced671b30fec1330ad400b89ea3b355fcb0b581b8
  HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/mujs.pc" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    "-DPACKAGE_VERSION=${VERSION}"
  OPTIONS_DEBUG
    -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-mujs)
vcpkg_copy_pdbs()

vcpkg_install_copyright(
  FILE_LIST
    "${SOURCE_PATH}/COPYING"
    "${SOURCE_PATH}/SpecialCasing.txt"
)
