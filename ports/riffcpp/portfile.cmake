include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libdmusic/riffcpp
    REF  v2.2.0
    SHA512 e595a74aa4b49d6948beeaddaa2c51313f006482bc88afebf5a7ece4be5c864ec798169047e913545e9a4850b7de4c0a2b6b73d4d3a56a1ada7edf946e78ceef
    HEAD_REF master
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DRIFFCPP_INSTALL_EXAMPLE=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/riffcpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/riffcpp/LICENSE ${CURRENT_PACKAGES_DIR}/share/riffcpp/copyright)
vcpkg_test_cmake(PACKAGE_NAME riffcpp)