vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/NVTX
    REF 2942f167cc30c5e3a44a2aecd5b0d9c07ff61a07 # 3.2.1
    SHA512 73566c4aef45968bbaca7eb6fdfda1224b3c7912c2ef797af3462df40c182318585de93d3351d50ead35f3be5fb9444ba60673de757d5bc188f20c1756884f0a
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
vcpkg_cmake_config_fixup(CONFIG_PATH "/lib/cmake/nvtx3")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")