# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kobalicek/ppmagic
    REF 2c7894e3056c610d383027b2d48149ba9d4a1c62
    SHA512 4ab5f1dbef4c9b7892d8042e2a2b01df21a201b2b05a1b75a6ad594f50e2ec1c6a3e4782bb1d702266c90440df679d7eb24dfe595ce35680f7d263ec6c371a3b
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/ppmagic.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
