
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO apache/avro
  REF release-1.9.2
  SHA512 6a6980901eea964c050eb3d61fadf28712e2f02c36985bf8e5176b668bba48985f6a666554a1964435448de29b18d790ab86b787d0288a22fd9cba00746a7846
  HEAD_REF master
  PATCHES
        install.patch

)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  INVERTED_FEATURES
    snappy     CMAKE_DISABLE_FIND_PACKAGE_Snappy
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/lang/c++
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DAVRO_ADD_PROTECTOR_FLAGS=1
)

vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "linux" "osx")

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/lang/c++/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
