vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO apache/avro
  REF bf20128ca6138a830b2ea13e0490f3df6b035639 #version release-1.9.2
  SHA512 23db13fc71997cde8e7b897171a72d09bedec156496acff1d75b92ff54f0149dfae374a0067d1dbd0c9d5008f9e302457bc1999987848a97b5c0a407377ea438
  HEAD_REF master
  PATCHES
        avro.patch
        fix-build-error.patch # Since jansson updated, use jansson::jansson instead of the macro ${JANSSON_LIBRARIES}
        snappy.patch # https://github.com/apache/avro/pull/793
        fix-finddependency.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/lang/c
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/lang/c/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
