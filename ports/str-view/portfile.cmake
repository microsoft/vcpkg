vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS https://github.com/agl-alexglopez/str_view/releases/download/v${VERSION}/str_view-v${VERSION}.zip
    FILENAME str_view-v${VERSION}.zip
    SHA512 46343734382ba4f17286069b42dbb3d94a69b74c5836f09bf552a287d902c2f07f79829220029bff74e190d73aa2ff3b3000fc2487e862f74249331dce778cbb
)

vcpkg_extract_source_archive(
    src
    ARCHIVE ${archive}
    NO_REMOVE_ONE_LEVEL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${src}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "str_view"
    CONFIG_PATH "lib/cmake/str_view"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${src}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
