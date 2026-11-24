set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF "v${VERSION}"
    SHA512 3ccfd7b1052fdeff6e64298cc7e8aef5c9e2e36e20a09ff3dc84c99720a813db8138b235bf36958fac5411cf080c9de07bd3accf54982128763e5d29daac79ce
    HEAD_REF master
)

# Copy the library headers
file(COPY "${SOURCE_PATH}/Include/WinReg" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
