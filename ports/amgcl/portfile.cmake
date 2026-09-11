set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ddemidov/amgcl
    REF "${VERSION}"
    SHA512 c0faa4894dfb797404afa749bde14721be3bf828c6bbf9538eb7caea180bfca9bcf2952a420cce2914ce532203065b5b739188bc000005801a84120bba4e7e33
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/amgcl/cmake")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.md"
)
