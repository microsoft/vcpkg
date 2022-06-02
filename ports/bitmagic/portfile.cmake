# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tlk00/BitMagic
    REF v7.11.2
    SHA512 0
    HEAD_REF master

)

file(GLOB HEADER_LIST "${SOURCE_PATH}/src/*.h")
file(INSTALL ${HEADER_LIST} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
