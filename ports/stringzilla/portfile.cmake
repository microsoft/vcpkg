# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 6f79c33326f93a51d420fd3bbc1e7a667917f42615197356ff61f6abd92934790a5ab01ff8cd63c74956220447dacec4af4165d33cd9afcbe731e1e9e84dc8a2
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
