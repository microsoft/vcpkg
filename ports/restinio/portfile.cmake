include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF v.0.6.0
    SHA512 70c37a9b88db5eef0591baf0adc8227c1103a4f272c8fcd332410b9481854f5ae8f2385c8070c7eab17e8a75e699cded528fc655fbdef3553203914abb379b3a
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/vcpkg
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/restinio)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/restinio)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/restinio/LICENSE ${CURRENT_PACKAGES_DIR}/share/restinio/copyright)
