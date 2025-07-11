set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/iguana
    REF "${VERSION}"
    SHA512 278d96bc3586104904c91bd62c5579b1db6a844ab5ef64ba3853f55bd04852cf7c035e4c88211bbab3348fba662edab5e6fd1df0d113d41cfed7b455467f9fb3
    HEAD_REF master
)

file(INSTALL
    "${SOURCE_PATH}/iguana"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
