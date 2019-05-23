include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/breakpad
    REF 21b48a72aa50dde84149267f6b7402522b846b24
    SHA512 4ca2f877871c0a79c24ce4cc592dddb3ac4c2eac2a5962dad6d3d94edc91ac82afec3d7e4e7f81e7d9916eb83f8708e66759c38a6ef0e1b2c19691dd1518558a
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-breakpad TARGET_PATH share/unofficial-breakpad)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/breakpad RENAME copyright)
