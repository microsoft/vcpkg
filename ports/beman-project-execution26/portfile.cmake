vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/aminya/project_options/archive/refs/tags/v0.41.0.zip"
    FILENAME "project_options_v0.41.0.zip"
    SHA512 a2c74a061b68135be1c531475f12ee5be30731fe2fab535a9b05ed9a93f50c0b18d7acb3f6d1448ed36f2826229bb1f1281cf7c40de1f07ce977ffb01ee485dd
)

vcpkg_extract_source_archive(
    PROJECT_OPTIONS_SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beman-project/execution26
    REF b8b689b7e08d3960d1a097cd8579ad4f17eff503
    SHA512 c6bb9bbe66d1d5a6a72bfb4977b42410be1a27df45417894cb19ac290e4d638fa7cb283697802cf8371201311a84b662a0f1d674fcfba3237003fd247139b4e3
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        "-DFETCHCONTENT_SOURCE_DIR__PROJECT_OPTIONS=${PROJECT_OPTIONS_SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(PACKAGE_NAME beman_execution26 CONFIG_PATH lib/cmake/beman_execution26)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
