vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO romeric/Fastor
    REF "V${VERSION}"
    SHA512 6f636cf93b6fcd3fed83c4c7e4d0e762c2ca03368cc5fa38805913173a35b5919a030190744edc90e13ba4e463f1be742b1aa97b849cc48e93d9bcb6b635774a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

