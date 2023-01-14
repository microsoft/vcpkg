vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/boostorg/nowide/releases/download/v11.2.0/nowide_standalone_v11.2.0.tar.gz"
    FILENAME "nowide_standalone_v11.2.0.tar.gz"
    SHA512 c3748921b85648aa0e89970f2ab24588cbc72d05edd7ddf4f61a607d9ecbddd45e9e6799d2ed83386c43045b9487693e027494a81b11a6a7bdfaa939d1251938
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/nowide)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
