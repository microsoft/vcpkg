vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/BlessingNyuwani/marona-cpp/releases/download/v${VERSION}/marona-cpp-${VERSION}.tar.gz"
    FILENAME "marona-cpp-${VERSION}.tar.gz"
    SHA512 1fa3aac151800e30bc59adca8e4dd7b8de5ecbc142bab3af100269905be2839550c1a0ff19ab1abc21131489581e5e762430d91344c5f6b99c2869b8f1950f97
)
vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMARONA_BUILD_TESTS=OFF
        -DMARONA_BUILD_EXAMPLES=OFF
        -DMARONA_USE_SYSTEM_HTTPLIB=ON
        "-DMARONA_JSONCONS_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME marona CONFIG_PATH lib/cmake/marona)
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE "${CURRENT_PACKAGES_DIR}/share/marona/README.md" "${CURRENT_PACKAGES_DIR}/share/marona/LICENSE")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
