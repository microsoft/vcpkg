set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/iguana
    REF "${VERSION}"
    SHA512 528dc6e21872d25890127b74da55f88652ac7ca09216ba9546a27135b2451da53a070c46085abbb9de2480059f7ab9adc4ff851082f548a4408eea316097ed1f
    HEAD_REF master
)

file(INSTALL
    "${SOURCE_PATH}/iguana"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/iguana/version.hpp" "#define IGUANA_VERSION 100005  // 1.0.5" "#define IGUANA_VERSION 100200  // 1.2.0")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
