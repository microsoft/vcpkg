# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 39960839dfa6a8bfda966df06c6f8d8786754605583f9c8cf319a8c733c0fdfb9ec5d06f962873a705b051d53156f903a1652e462d04b59a014dd0ec6dcaad39
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
