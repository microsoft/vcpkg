# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 436b2b639d9d66d62d618d07174231f4e4dd9855edc6e03a5746c8c2f5205c2af9be9dfbf88a95fc12bb8d4abfffdf925fd85c0bd14b5ab3734d2f1105990f41
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
