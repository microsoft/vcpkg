# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDAlgorithms
    REF 93023b7b6640a227cfa6b2e7f1b8e72d10a0b981
    SHA512 151488c5ba30fceee204278e620bbc509464cb993d4207891ba627cb4384dc585927336f263ea80bfeb46f5100fdb31edcef13482d4b7f70b79480d1b153f087
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/src/kdalgorithms.h" "${SOURCE_PATH}/src/bits"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
