vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/boostorg/nowide/releases/download/v${VERSION}/nowide_standalone_v${VERSION}.tar.gz"
    FILENAME "nowide_standalone_v${VERSION}.tar.gz"
    SHA512 81bd088024a4682f4caf7524358982cdbdd4657b7533f4bb5135a88d228a74c4c3afee7ca2e13af8ead291450b6ef5f6849685875ef0f2aabe8eb9f0cab20688
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/nowide)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
