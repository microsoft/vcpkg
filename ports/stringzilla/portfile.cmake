# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 7f1f3c0df25232cc688bdbed966a4ef6a6050dcf43d1b38b11723051c728e0244e889a8eefc8bdf5dca144c847c924a35fe4512c02f219d9d5430eed46d3f684
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
