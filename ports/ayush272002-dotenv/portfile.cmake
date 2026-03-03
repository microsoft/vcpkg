set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ayush272002/dotenv
    REF v${VERSION}
    SHA512 d91516a2cf13712d28abc8196309e09d08a4349a1d68eae951d58a590e090124c280f7d2dbd2126a98c806357a797f57375a73dab46bec92260cc515167f297c
)

file(
    INSTALL "${SOURCE_PATH}/include/dotenv"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
