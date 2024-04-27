# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 3b2932fe9a0a09f48e25d905c7f1514d4f8216466d21d50251e6c97744b9f8d375ce28e5e09b5341df5c7d9d1aedf850a65ce7c0a543f6394f862c1afd9c4724
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
