# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 65bb238b07521e6efeff15caa4abf6a8d15f66a5635e0b68e7ba255149f30cf56e76d91f183789093e45593639cb9f397d2cbb8bb02033179fbd150018e2c234
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
