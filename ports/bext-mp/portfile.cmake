vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qlibs/mp
    REF "v${VERSION}"
    SHA512 09cfaf9d6b6622467902902bb71bc71c14fc700de0f52362e67ffcf47b058938c184c75fd0c433697d9e25b1cd4f9df7c6bac08bfe7575772fccd3ab05a4177f
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/mp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/.github/LICENSE")
