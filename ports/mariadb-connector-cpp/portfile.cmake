vcpkg_download_distfile(ARCHIVE
    URLS "https://codeload.github.com/mariadb-corporation/mariadb-connector-cpp/tar.gz/refs/tags/${VERSION}"
    FILENAME "mariadb-connector-cpp-${VERSION}.tar.gz"
    SHA512 efc0d7866b76b1baa20ab6bbbeb45825ca5e3d8b460e09805343f0e6b638bb0cfcd812d01bd183c5c0077eece5f1bdd5f207e753aa54b5ed218576b7cb37b241
)

vcpkg_download_distfile(ARCHIVE/libmariadb
    URLS "https://codeload.github.com/mariadb-corporation/mariadb-connector-c/tar.gz/refs/tags/v3.4.0"
    FILENAME "mariadb-connector-c-v3.4.0.tar.gz"
    SHA512 634aa71d0202634117c88dc82da060eb6b7c50afa3607301fecb7e15ad0d370175dec762b2be97072deb53bce9f2de5bf8f3da35fdf5abdf58635f56418b06da
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")