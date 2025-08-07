# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 1ec86fddf8fdc118bc0aaec5cf3d6a34b2e20572f2f8f7dcf33b50637faa7b8be6c04ae5be9df28fce6b0859fd75f4a6c76d39e8663fea965b8b40389433e2d4
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
