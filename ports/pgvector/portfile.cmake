vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pgvector/pgvector-cpp
    REF "v${VERSION}"
    SHA512 e0529e50f5852a31b36cdae445bdf27297b01b745f685e570c55fb577c484f63b95f729030f796ceee38ea1f1b7d16c9c162ace6f30179a7ba4a44c0a15b6a1a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
