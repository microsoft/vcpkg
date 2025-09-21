# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 3fc405a352a7c040a04c1aa9932a45b74c4af79abc84d9ce50b73031ee637f9d21b37a85e4cc5076722d100d349a447b4987af5d1545b084bb4a70dd780366be
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
