vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO michaelrsweet/mxml
    REF 0d5afc4278d7a336d554602b951c2979c3f8f296 # 4.0.4
    SHA512 29bb9785de32d3ba72535179856247f9b4ef466857f42a0576ed88175c807ca64fe4f9ee4cfef1ba57fb44780af26649316fb7baa1770e7d298d1cf13dff17cc
    HEAD_REF master
)

# Build:
vcpkg_msbuild_install(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH "vcnet/mxml1.vcxproj"
    TARGET Build
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
