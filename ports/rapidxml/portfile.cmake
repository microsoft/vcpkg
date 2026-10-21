#header-only library
vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rapidxml/rapidxml
    REF rapidxml%20${VERSION}
    FILENAME "rapidxml-${VERSION}.zip"
    SHA512 6c10583e6631ccdb0217d0a5381172cb4c1046226de6ef1acf398d85e81d145228e14c3016aefcd7b70a1db8631505b048d8b4f5d4b0dbf1811d2482eefdd265
    PATCHES
        0001-fix-for-a-bug-in-gcc-that-won-t-let-rapidxml-compile.patch # https://sourceforge.net/p/rapidxml/bugs/16/
        msvc-alloc_func.diff # rapidxml.hpp(385): error C2059: syntax error: '<parameter-list>'
)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")

# Copy the header files
file(INSTALL ${SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/rapidxml FILES_MATCHING PATTERN "*.hpp")
