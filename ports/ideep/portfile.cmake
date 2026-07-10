vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/ideep
    REF e087b6e4b32a7ba684db82231d1558123968ac1d
    SHA512 7458481aafc066a5e73bc4406b7309c93cbc9ec2c9f3d298cb43a10418f751ca7c5638fb2195d38b484e07c1975b1b27ba7ff3876bfca2afe86fb3abab05a120
    HEAD_REF master
)

# Header-only library: install the include tree directly.
file(COPY "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
