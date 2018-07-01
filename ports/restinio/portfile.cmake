include(vcpkg_common_functions)

set(RESTINIO_VERSION 0.4.6)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/restinio-${RESTINIO_VERSION}-vcpkg)
vcpkg_download_distfile(ARCHIVE
    URLS "https://bitbucket.org/sobjectizerteam/restinio-0.4/downloads/restinio-${RESTINIO_VERSION}-vcpkg.zip"
    FILENAME "restinio-${RESTINIO_VERSION}-vcpkg.zip"
    SHA512 5b0777998617164dd6b7c5944feafdfef8849b79fd6f2a396f381c4f563a862a815837a4085ef7dbb980595774eb4cccd9368c0a2cc5a88b0cb8e8cba864fb92
)

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/vcpkg
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/restinio")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/restinio)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/restinio/LICENSE ${CURRENT_PACKAGES_DIR}/share/restinio/copyright)
