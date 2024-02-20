
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO midi2-dev/AM_MIDI2.0Lib
    REF "v${VERSION}"
    SHA512 fc8b937fd28fe616c58c3e9991e50e262a791c0aa457d9d1263825a5264ae16385a89752cca66d4864bc4f68df329d1c4fa59f6af2aa937a829932b1c263450f
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

