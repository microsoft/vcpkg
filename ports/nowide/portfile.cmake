vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/boostorg/nowide/releases/download/v10.0.1/nowide_standalone_v10.0.1.tar.gz"
    FILENAME "nowide_standalone_v10.0.1.tar.gz"
    SHA512 b349983127532fcfcb2bd29ce327634ea8d980e1da6a67fe44d0a5761a81c6cc78e518439970099b155732c3edb0fa8f1f1a1df5018d59b8cb699626c121f95e
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
