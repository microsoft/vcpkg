vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(
    ARCHIVE
    URLS "https://github.com/rerun-io/rerun/releases/download/${VERSION}/rerun_cpp_sdk.zip" # Replace with the actual URL of the zip file
    FILENAME rerun_cpp_sdk.zip
    SHA512 1351dd0937d6ddf73622b69a803a7233eb92e5ec52607fc1c775accd015d52eaf3259c0aea64cfac3109f1c55218fb6a4597bff5b067ccdd194cd8695b3f4c8c
)

# Extract the zip file
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DRERUN_DOWNLOAD_AND_BUILD_ARROW=OFF
)

message(STATUS "Packages directory: ${PACKAGE_PREFIX_DIR}")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME rerun CONFIG_PATH "lib/cmake/rerun_sdk")

vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/rerun/rerun_sdkConfig.cmake"
    "${SOURCE_PATH}/lib/librerun_c__macos_arm64.a"
    "\${PACKAGE_PREFIX_DIR}/lib/librerun_c__macos_arm64.a"
)

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE-MIT"
    "${SOURCE_PATH}/LICENSE-APACHE"
)

# Cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")