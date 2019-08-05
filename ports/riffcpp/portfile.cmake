include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libdmusic/riffcpp
    REF  v2.1.0
    SHA512 bf41876b2d2305d5ec83dfb2739becf4c9d584248022123c985f5a49ccf051a53f2453b715052ae4fb96e57ab1191001572139803c7c36f37f97c6e21c59d1ba
    HEAD_REF master
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DRIFFCPP_INSTALL_EXAMPLE=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/riffcpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/riffcpp/LICENSE ${CURRENT_PACKAGES_DIR}/share/riffcpp/copyright)
vcpkg_test_cmake(PACKAGE_NAME riffcpp)