# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 3b6ddeb5d8af5f50603a3f4067293f4a9df88122e66225317d63cc88f0ccd10827eddff5c5e8efaae98710f7009bcf87d180da41111600581f9e60444dd68f86
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/module.modulemap")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
