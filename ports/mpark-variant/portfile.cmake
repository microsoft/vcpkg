include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpark/variant
    REF v1.3.0
    SHA512 53735d14a9b241d93191fa3b7ac8ed8fb17a8f8766318b2817c4dd1948088377190ca168027a297bae41bb2cc1f6043fe51752d43b8c33badcc9f2df9fa08ece
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/mpark_variant TARGET_PATH share/mpark_variant)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL
    ${SOURCE_PATH}/LICENSE.md
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/mpark-variant RENAME copyright)
