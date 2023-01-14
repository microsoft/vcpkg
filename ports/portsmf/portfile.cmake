vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tenacityteam/portsmf
    REF 238
    SHA512 af619d1b0a656361af8f8b8b65d7f98047613ac8e9ea51354031629c1732ad02755f84d63ac7c4ed24cdf0ad3db46381061bf32d9afe29b7be3226dc814ef552
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/PortSMF)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
