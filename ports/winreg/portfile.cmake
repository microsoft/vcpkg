# WinReg - Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF "v${VERSION}"
    SHA512 7a2edf11f180e387b908d5bdc39e0c4806d548adf60fbde904af05ce2c8a8a937cfba35baf2cd8bd16ee96e56fd1199988c280629be0fdecacc56ba5735ffc3d
    HEAD_REF master
)

# Copy the library headers
file(COPY "${SOURCE_PATH}/WinReg/Include/WinReg" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
