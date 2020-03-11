include(vcpkg_common_functions)

vcpkg_buildpath_length_warning(37)
vcpkg_fail_port_install(ON_TARGET "uwp" "linux" "osx")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO apache/avro
  REF release-1.9.2
  SHA512 6a6980901eea964c050eb3d61fadf28712e2f02c36985bf8e5176b668bba48985f6a666554a1964435448de29b18d790ab86b787d0288a22fd9cba00746a7846
  HEAD_REF master
  PATCHES
        avro.patch          # Private vcpkg build fixes
        snappy-pr-793.patch # Snappy build fixes for Windows (PR-793)
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/lang/c
    PREFER_NINJA
    OPTIONS
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/lang/c/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
