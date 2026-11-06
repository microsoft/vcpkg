vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zenomt/rtmfp-cpp
    REF "v${VERSION}"
    SHA512 c051ddc289f5b1a0d211058f9ed388e3219f796d97de5c403a70c715ec811efcfe1e7526996672687b42c9a45d57bccd5fa9b03415633d6341e3534ae24cd39c
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_REQUIRE_FIND_PACKAGE_OpenSSL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/rtmfp)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
