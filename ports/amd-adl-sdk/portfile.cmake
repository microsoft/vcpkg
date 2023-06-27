vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/display-library
    REF "${VERSION}"
    SHA512 e65bcb840929bfcc840abb361d92245c511948567c659e75f0b2784dc869cd851904819e71281afde5b4f3000ef0de7e3d33a32e5102110a26daca898414ceae
    HEAD_REF master
)

# Install the ADL headers to the default vcpkg location
file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Public-Documents/ADL SDK EULA.pdf")
