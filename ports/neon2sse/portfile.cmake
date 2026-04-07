vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/ARM_NEON_2_x86_SSE
    REF fc2c9d710c7a9adf61a4b286a4af2eeff6d0d531
    SHA512 17e674a0a9c3292a1072951b0bfa9ca32c69686c346377d00726a917b49cc8b898773d5c4b0d3e8b1c970988d5a162dcf63f132151fb438b225bddf441a6a42b
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME NEON_2_SSE CONFIG_PATH lib/cmake/NEON_2_SSE)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug"
                    "${CURRENT_PACKAGES_DIR}/lib"
)
