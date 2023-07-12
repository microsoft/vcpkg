vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/boostorg/nowide/releases/download/v${VERSION}/nowide_standalone_v${VERSION}.tar.gz"
    FILENAME "nowide_standalone_v${VERSION}.tar.gz"
    SHA512 68e4d4b11db7265bf91e90b16e35ef2ea3a8ad80031b122067393a4cb89e20e26bacff81c7abddfc7a84d22c0d545875d7ba40b0288c665fb82028f08f957524
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/nowide)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
