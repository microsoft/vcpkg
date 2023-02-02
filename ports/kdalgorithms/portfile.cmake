# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDAlgorithms
    REF 45501fa595dfda00d6af44bfadbf4520cc4e07c1
    SHA512 69cdc6644b16fff0eb494e9b21082ae32e0b437e225a161ecf644ad83b74d2957ed97e8b6b5674778b4d2c68b2be02ae4e90c1a30b8c8d1eed79e758d4d4b10e
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/src/kdalgorithms.h" "${SOURCE_PATH}/src/bits"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
