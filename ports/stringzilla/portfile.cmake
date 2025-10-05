# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 32ebd01005596984ec3a73ca437fd089aefce77c4af2723fa475c61d88591d425e89457f7869cbe38c5a133a2f08ea4fbb994f6478fa71a0e77d8d2439bd5cc8
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
