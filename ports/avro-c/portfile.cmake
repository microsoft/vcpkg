include(vcpkg_common_functions)

vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO apache/avro
  REF 89218262cde62e98fcb3778b86cd3f03056c54f3 # release-1.9.1
  SHA512 b5e038ea9d58a78d15cf435c45261e2307accab6718668e2e8deaf4a95d19262a31d2b89553bd1b474cd2a4b558b1f2f6ca0bfb8c8266ded605e25c08cec8664
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
