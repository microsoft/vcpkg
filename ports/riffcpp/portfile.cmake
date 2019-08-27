include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libdmusic/riffcpp
    REF  v2.2.2
    SHA512 2124208e0e75bfe6d96fd177594ea038291e2bbf88c3a1fddb9cede0966168748de43844a379253947797baf184d85ca0fa521edbf9001cf9c5e471356f1603d
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