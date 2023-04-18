vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emil-e/rapidcheck
    REF 1505cbbce733bde3b78042cf2e9309c0b7f227a2
    SHA512 4759f84ee71f08108e0ad61436c940e96f494816d6b0d1fda64d880a6cb2eaa54f6422fa2ae680564d8cb8bd52b3589a4a92bed9422077d9b1ee4ee874b6ef7e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRC_INSTALL_ALL_EXTRAS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/${PORT}/cmake")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
