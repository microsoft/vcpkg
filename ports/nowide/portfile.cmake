vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/boostorg/nowide/releases/download/v11.1.3/nowide_standalone_v11.1.3.tar.gz"
    FILENAME "nowide_standalone_v11.1.3.tar.gz"
    SHA512 8e493b9ee7f3f218dcc1a0c2f040c040f8f3d10ec7c204caee92986a2cc54d4fc06f530b13e7b14cfdbbd42fd106e151916e2f8fae524a051688d6785d7c2993
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
