set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/iguana
    REF "${VERSION}"
    SHA512 dc0e3002ade1075c7a8be8146e891aceb9b6a4ccc12a918f5c74c99f0aee8d47b087f4ca220115146c7b40ee40ae9187f81570b87aac442aea677df8f2cd19d8
    HEAD_REF master
)

file(INSTALL
    "${SOURCE_PATH}/iguana"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
