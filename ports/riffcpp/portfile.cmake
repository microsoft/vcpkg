include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libdmusic/riffcpp
    REF  v2.2.1
    SHA512 646a98e6f6cd3995081a6242a866effab2968e20b2700248e3d19036bed426236e3844ad09d4b542e023f5f280d74575c47abe5e5e94ce0d77536f4f0a33b8c1
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