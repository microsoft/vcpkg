# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 b42acd6f1a06f8c5519f3093ac155b6caea95ca4a5618bfc24b9028353c78ae47c53f37cd498ce9d652ede323b96d38d044faa45f6c4ef58d71d748c071cbd21
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
