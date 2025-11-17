# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 2b0845e4012274020ce18b5025b219608001851cd6a0d32edfb1e91f87fba49f3c6a4361005cf5ead3d743ce8a5f7f744cf0ec97e5464274d1cfe8de014da714
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
