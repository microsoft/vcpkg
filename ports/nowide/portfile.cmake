vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/boostorg/nowide/releases/download/v11.0.0/nowide_standalone_v11.0.0.tar.gz"
    FILENAME "nowide_standalone_v11.0.0.tar.gz"
    SHA512 315b56e2e6cfe26459e71bc664953b6e5b81351e409dd8f63d6848a49fd5d5834e39f1ed4de28ce0ed288332d71b63a5ddac9894531d42181f23eaf627d077ac
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
