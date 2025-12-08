vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO avaneev/lzav
    REF ${VERSION}
    SHA512 63875b20f14a945fced93844e80648591be181a0468f9c42e85bfa8f692144f1aad0cf33c18b9225f49027cece15c3262e50ddfb6b855096fa46cb604f3d1701
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/lzav.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
