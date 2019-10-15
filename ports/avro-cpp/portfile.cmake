include(vcpkg_common_functions)

vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO apache/avro
  REF release-1.9.1
  SHA512 7732ac648b99bede4c57610e2db0bf229e5c672da255c0cd3f09272b0f6d4851fd93e60bc8661a1629fc7140d1596067215108cf5a10d81629bb404f478c68d2
  HEAD_REF master
  PATCHES
        install.patch

)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/lang/c++
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Snappy=ON
)

vcpkg_install_cmake(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/lang/c++/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/avro-cpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/avro-cpp/LICENSE ${CURRENT_PACKAGES_DIR}/share/avro-cpp/copyright)
