# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 65d5ff92352551a77ff37da27ff8803a77ac63caa5dd95500aa4ea9b28aa00984433faf51b2a65ac5ea37e211e111be8f3d5b60fb6126885bb3df868731b9e74
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
