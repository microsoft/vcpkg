# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 3e304364aa9fdfc61a22c516f610943d0635d7775a9d9020d9a4ab3a02c062131d97943a88ac82384f9e65fdb2c05641425efdcf9f2da6a42879fe95f62e454e
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
