# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Pravila00/enumflag
    REF 0b6697149a68e9700029840e8ab983c06001e454
    SHA512 2c583bf1dfd4d42dd2589d78da288093c49f1b601da415f524f2201bbb49bf1fc22f1c027874a52e8665dadbe0f5f676c278e0bced0c53cf834a0eab02d454b4
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/EnumFlag.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
