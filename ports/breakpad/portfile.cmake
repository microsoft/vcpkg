include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/breakpad
    REF f12b6897897fb5b7e74437371fdf2b36a36f5661
    SHA512 b2322e2f043fff9f7aa9ff1aa99bc7eab2c98e0d0e2407bd35aa5eeab6e16e4a526d5a88544e3c13f0b41ee0c993f35eefce632ef8a3f183a877f98272ac7f19
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
