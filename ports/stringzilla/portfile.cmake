# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 c14f1281143f061906497b7a36de18e52bbc8f47cd7da8348036afe0a8db57cc50de2cdb842650efefe029b10d3d2ee0f82eadba4b2fc1888bbc3cb5c987b3bb
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
