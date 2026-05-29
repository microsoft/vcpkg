set(VCPKG_BUILD_TYPE release) # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO UniStuttgart-VISUS/datraw
    REF "v${VERSION}"
    SHA512 45c79ae6deaa1434782d3372a036211889ae7dc883b368136d83648718f8c1b23d08206ba30c99aca02ee22d2c9a044313a066d43ed461fa563b1eca3ed90870
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/datraw/datraw.h" "${SOURCE_PATH}/datraw/datraw"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENCE.md")
