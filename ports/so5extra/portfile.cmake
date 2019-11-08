include(vcpkg_common_functions)

set(VERSION 1.3.1.1)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/so5extra
    REF v.${VERSION}
    SHA512 aaf0d6bf86819a5c8c4e2c07318b46e34f22f0b4c2183690d8f21b8789a3c8c2533304998432397b8192193e32915ba4742eaff3481949add1a25602fb7347f1
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/dev/so_5_extra
    PREFER_NINJA
    OPTIONS
        -DSO5EXTRA_INSTALL=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/so5extra)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/so5extra RENAME copyright)
