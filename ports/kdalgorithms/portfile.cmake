# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDAlgorithms
    REF ${VERSION}
    SHA512 2229712954c377e9167b78fc931988f33c82349baeae9a64e3506f66fd96508e8482ce777c4ef8928c2ab38cbeffc413e96c75a9f41902080230f8c434782232
)

file(INSTALL "${SOURCE_PATH}/src/kdalgorithms.h" "${SOURCE_PATH}/src/kdalgorithms_bits"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
