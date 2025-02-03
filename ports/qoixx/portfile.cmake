#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wx257osn2/qoixx
    REF v${VERSION}
    SHA512 1d2ef5d60ab89f2b284d919870eb7fac3adc6e36102d69c750341827564374038454497378e7b40bca2f34446bc5e1da9f046752ee6bc3a03956b4469948f1af
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include/qoixx.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
