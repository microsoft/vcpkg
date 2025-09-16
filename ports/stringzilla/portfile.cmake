# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 0846227e430fefbdef50f42798a61616e29919b23bdb355f20ce19ab3dafd894d28187b7a55f2b7abc660deefabcd87b6dd99ab387fceaf8008d92cc628701bf
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
