# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 2ff6983543ed8a2b5a102098a590e4c88a6bd05b185155b99a943f1302bc94dd80e26b66caecd33182e437c9126f6800fbf4ed368642e72cb580ad995b829527
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/module.modulemap")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
