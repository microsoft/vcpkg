# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dpilger26/NumCpp
    REF fc68d897f8c2ae4f5b14baff3eefda897351abbd # 2.1.0
    SHA512 ce407d9782d304658853cd66ba5901a4dc84d8cf74d45b2dd466ca6328f6bf60b39906efd5373624df6b46c4253f861208b15254d0e156fdb09f32ca731ad2bc
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DNUMCPP_TEST=OFF
        -DNUMCPP_EXAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/NumCpp/cmake TARGET_PATH share/NumCpp)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
