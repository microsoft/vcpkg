include(vcpkg_common_functions)

set(RESTINIO_VERSION 0.4.5.1)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/restinio-${RESTINIO_VERSION}-vcpkg)
vcpkg_download_distfile(ARCHIVE
    URLS "https://bitbucket.org/sobjectizerteam/restinio-0.4/downloads/restinio-${RESTINIO_VERSION}-vcpkg.zip"
    FILENAME "restinio-${RESTINIO_VERSION}-vcpkg.zip"
    SHA512 198153f9b8d866c2aa57932720b31ff1f8e523d9640ad0c8becb911afed1fa12caa636847234cfc83d584a15bdc4b05fb98cbc4730af2520b453c5de468eb7fa
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
