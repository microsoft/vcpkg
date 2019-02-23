include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/gocha/sf2cute/archive/v0.1.zip"
    FILENAME "v0.1.zip"
    SHA512 aa7e96e7b23b2050ea64ab41c56206fb37e1da62e76fdfb6c09148ee3f181ca71c3acec575837e79b1f541d8627c7a3095f211560b584d558267b3059a28f7e0
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(COPY "${CURRENT_PORT_DIR}/cmake/sf2cute-config.cmake.in" DESTINATION "${SOURCE_PATH}/cmake/")
file(COPY "${CURRENT_PORT_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSF2CUTE_BUILD_WITH_EXAMPLES=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# move the .cmake files from the given directory to the expected directory by vcpkg
vcpkg_fixup_cmake_targets(CONFIG_PATH share/sf2cute)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/sf2cute RENAME copyright)

# Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME sf2cute)
