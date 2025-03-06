# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 9310283057aec46c8d83b7e1f2d7d4d9a1d551e3617ed98f5fa8d43e9ddfc49ddf6662d5ef1a0db8fa32bff05f3af31b4c4cb17d2d83f421a9371beab716280a
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
