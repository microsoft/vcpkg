include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/re2
    REF f2cc1aeb5de463c45d020c446cbcb028385b49f3
    SHA512 68df93cac6916cf5d944b57de505f7c592dcc66bbe003dbaffdf88cfd6648787a272740a861d8c8440ff2888434776141a7710b326907687285f8e9340be127c
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DRE2_BUILD_TESTING=OFF
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/re2 RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
