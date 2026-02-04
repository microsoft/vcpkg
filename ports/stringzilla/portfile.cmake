# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 a97ed147be78164b01e61ff4aeae8efb8eba23204edf48ed7701786cbc85b8c6d09f1802aa3cf0f65ca140bdccb4e8c3518a56b2b910466fc8d040f2b0293716
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
