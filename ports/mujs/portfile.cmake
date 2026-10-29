if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ArtifexSoftware/mujs
  REF "${VERSION}"
  SHA512 4d841547a63d9d527e0034b3eae009264133c19a91e5230372007db4c91963ab2666f3000ba23344f01d74c271d8f975dab76fdbdd57b4ac7f3d6ddaaccb4c59
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
