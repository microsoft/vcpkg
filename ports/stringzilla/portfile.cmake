# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 9135f12c8df582d7e8a73eb6c18f2ab1b4aee3cd7052e8d88dcbb3134eed508ab41bdca7c05758c8587866cf03f769c8da0433115c3b28a9fa0cd434de17edef
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
