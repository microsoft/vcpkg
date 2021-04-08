vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/boostorg/nowide/releases/download/v11.1.1/nowide_standalone_v11.1.1.tar.gz"
    FILENAME "nowide_standalone_v11.1.1.tar.gz"
    SHA512 fbb7763a5fe9307ac378367555d905e31457ed8b789f6d3b08cc498d7529ecdf7de31fe78272ecaaa46fc0c6402c06ddbe7e6a6fe5b5b3d7b8c0435f12076923
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/nowide TARGET_PATH share/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
