vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO avaneev/lzav
    REF ${VERSION}
    SHA512 cd324152adbf6fdeb53573bfd98f7e4e272529b9ed250137a6436f8348e5cfdf112b7b6396a0733c2b2160641bebf8916002fd64e7b4c6fcd150effacec1fe7d
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/lzav.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
