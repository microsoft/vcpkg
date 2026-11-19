vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open62541pp/open62541pp
    REF "v${VERSION}"
    SHA512 66fd895116bc616d4152a42bbe0f1a535a065d1fc1acef1c99b302e391c92b0bce42279bcb27b7b8b21a358d6752905c7c7105d2feb3313018b404a67b0b1405
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUAPP_BUILD_DOCUMENTATION=OFF
        -DUAPP_INTERNAL_OPEN62541=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
