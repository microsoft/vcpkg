# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 ddfc85994ca490a259766d4038d6cdcc455d057e9f0d64bb4338c7dfa3e75ee633c01e91ce4e2e7e0648b61eadf98fc1a08cbd69f6e0d7f8d5a8ae5d641a8cf2
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
