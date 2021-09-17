# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tlk00/BitMagic
    REF v7.2.0
    SHA512 74e7b32dcc66960a50e4976f82a0388d5e3b43c737c87277d5f2eac0f551866fca227704d61df867e6bd61e3dbc7b1de0e52ac48d732760f9dc7e50ecef9be6b
    HEAD_REF master

)

file(GLOB HEADER_LIST "${SOURCE_PATH}/src/*.h")
file(INSTALL ${HEADER_LIST} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
