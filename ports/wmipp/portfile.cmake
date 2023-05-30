vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sonodima/wmipp
    REF "v${VERSION}"
    SHA512 3cfa7bacc1e03077503fa04e636106ce5bfc66a3fce25e52033433c2328a62229fdf7baad4a0116459fb0c299839ea02507fe8da43c853b9dd8bcfcb3d2301d3
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/include/wmipp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
