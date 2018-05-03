include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/restinio-0.4.5-vcpkg)
vcpkg_download_distfile(ARCHIVE
    URLS "https://bitbucket.org/sobjectizerteam/restinio-0.4/downloads/restinio-0.4.5-vcpkg.zip"
    FILENAME "restinio-0.4.5-vcpkg.zip"
    SHA512 f5f135f761f29b2d4a9641ac1b37bb57bb6213df39b92ad349f8b73440142b2bd2a6093ee4c222417f61303ae46e960fb77b7a0c34d7e3924f3df1a50036b2da
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
