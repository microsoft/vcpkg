# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 d48069bc4e5c648a67132ddfe30943d3945e92682cd3faab97834164dbb0fa1b8023fca6428d5fd1b4e6a44fd9bcd7a943b4251e54e2dc16337021c5fa0d208f
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
