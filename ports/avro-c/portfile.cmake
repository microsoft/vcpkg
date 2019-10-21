include(vcpkg_common_functions)

vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO apache/avro
  REF release-1.8.2
  SHA512 a48cc353aadd45ad2c8593bf89ec3f1ddb0fcd364b79dd002a60a54d49cab714b46eee8bd6dc47b13588b9eead49c754dfe05f6aff735752fca8d2cd35ae8649
  HEAD_REF master
  PATCHES
        avro.patch
        avro-pr-217.patch
        fix-build-error.patch # Since jansson updated, use jansson::jansson instead of the macro ${JANSSON_LIBRARIES}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/lang/c
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Snappy=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/lang/c/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/avro-c)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/avro-c/LICENSE ${CURRENT_PACKAGES_DIR}/share/avro-c/copyright)
