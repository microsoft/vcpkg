# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 e6f108a57407d123b9387d0ea18447148d4bb0cdb98418ee620857db3c2e842fc02f1e9d798561bcc576c42c7df9a828f9d328907ddb9ebd40bcd2579be5e8bb
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
