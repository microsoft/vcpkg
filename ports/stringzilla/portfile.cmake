# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 96e7b199ba8f9c2b9669ff90e445d7e1145c06ad602665aa39e6979920bd5893c3b32bb423c49d30623e06600aa0b69e209c2a530b5deadc635eef30d2219d83
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
