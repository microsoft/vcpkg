include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/re2
    REF 71e6699778cebf99ed11e78e48b9370f79b9ea39
    SHA512 2d8499467eb4a5c0607f6814ea2d0bbdd5025b00a7ebd8bc7c8cd897ef39e21597b9ac01baf48d4f82613fb531c1e3562e63396e6b1fdfa3532b8b7af05f049c
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
