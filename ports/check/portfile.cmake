include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/check-0.12.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libcheck/check/releases/download/0.12.0/check-0.12.0.tar.gz"
    FILENAME "check-0.12.0.zip"
    SHA512 403454d166ddd4e25f96d6c52028f4173f4a5ad4a249dd782e3a8d5db1ad0178956d74577cf0d4c963a5a7d09077a59042a74f74d6b528b7212e18ab5def1dd9
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
)

vcpkg_install_cmake()

# make share
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/check)
file(INSTALL ${CURRENT_PACKAGES_DIR}/cmake/check.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/check)
file(INSTALL ${CURRENT_PACKAGES_DIR}/cmake/check-debug.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/check)

# cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING.LESSER DESTINATION ${CURRENT_PACKAGES_DIR}/share/check RENAME copyright)


vcpkg_copy_pdbs()
