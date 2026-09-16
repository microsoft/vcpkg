# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 9ccf58e020e1fa2f81b90a958c079d7d9a5c71cb23e0c7d025b8045c4736d82dd0a191982d0f27a51bc57094cb18fa2fed7aa6d044830a99d8e6aea7fe70fb1d
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/module.modulemap")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
