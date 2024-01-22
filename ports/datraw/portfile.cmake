set(VCPKG_BUILD_TYPE release) # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO UniStuttgart-VISUS/datraw
    REF "v${VERSION}"
    SHA512 f38401e0e878f8df8e1b7b9750f4e7fec6920495bfb914a694aab166a0ffbda6dec189693a0d5b9aadb760789706e255f49a382d4e902002aef7120033dce016
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/datraw/datraw.h" "${SOURCE_PATH}/datraw/datraw"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENCE.md")
