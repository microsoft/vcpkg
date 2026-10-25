# WinReg - Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF "v${VERSION}"
    SHA512 33339475bf247d76aabfffea62eae8c31941f9fa260369b84ce4bcd719924d85e603b1c33ed8cc41cf4f9c56511f540e67fd13e2efe612bc638896481dd329cf
    HEAD_REF master
)

# Copy the library headers
file(COPY "${SOURCE_PATH}/WinReg/Include/WinReg" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
