include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/igloo-igloo.1.1.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/joakimkarlsson/igloo/archive/igloo.1.1.1.tar.gz"
    FILENAME "igloo.1.1.1.tar.gz"
    SHA512 69d8edb840aa1e2c1df4529a39b94e2d33dbc9fb5869ae91a0f062d29b7fbb73d4e2180080e7696cb69fbf5126c7c53c98dddb003e0e5e796812330e1a4ba32e
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${SOURCE_PATH}/igloo DESTINATION ${CURRENT_PACKAGES_DIR}/include/ FILES_MATCHING PATTERN *.h)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/igloo/external/snowhouse/spec)

file(COPY ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/igloo)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/igloo/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/igloo/copyright)