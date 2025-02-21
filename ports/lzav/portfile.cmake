vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO avaneev/lzav
    REF ${VERSION}
    SHA512 456c1d422bf884643862f81d461baae75f24247a2789ea8dabd7203293fa73a197e5e6895492be57c12a9f8dace9d3dc810b8b1a3e4a264768dbda6e28e1ee59
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/lzav.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
