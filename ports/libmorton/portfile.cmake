vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Forceflow/libmorton
    REF "v${VERSION}"
    SHA512 020d9ba97204b8c028a8700d7212821dd75b6dbe1b4a77776777d06ef29bcad75cdc4e830f211daf6250779cc81ed4842a0632f89a7b7017eb071869a3c938fa
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/libmorton)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)