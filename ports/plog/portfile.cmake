# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SergiusTheBest/plog
    REF 1.1.5
    SHA512 c16b428e1855c905c486130c8610d043962bedc2b40d1d986c250c8f7fd7139540164a3cbb408ed08298370aa150d5937f358c13ccae2728ce8ea47fa897fd0b
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/plog)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/plog/LICENSE ${CURRENT_PACKAGES_DIR}/share/plog/copyright)

# Copy header files
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.h")
