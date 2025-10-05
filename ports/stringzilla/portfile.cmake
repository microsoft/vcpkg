# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 dd75f03eab2de1a0b54ce9fad5705f6091d7de1259d26218f94505398d9e7e431cd927bf031b81de88325d8a4d77790c62485101315f7e0a787fb2694d84cec7
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
