# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 7c5780585d9bd64f1d32d254bb49dc90539670c3779fc49ebdba4362ae7d821804c47c3c446f94f3333de8df53b76bfd2e9b4be9769c6811d9315db5fab7e642
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
