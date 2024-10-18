if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

# Convert PcapPlusPlus to add leading zero 23.9 => 23.09
string(REGEX REPLACE "^([0-9]+)[.]([0-9])\$" "\\1.0\\2" PCAPPLUSPLUS_VERSION "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO seladb/PcapPlusPlus
    REF "v${PCAPPLUSPLUS_VERSION}"
    SHA512 ae68a61a41915b1272aa7f8d1b70889216ea50e966c594d408d79fbca2667ff5aa073fe21a72c7e0916f744a925ac1e85e1d1f02e458b3f289201b88c8101fa3
    HEAD_REF master
    PATCHES
        0001-warn-STL4043-for-v23.09.patch # just workaround, which has been fixed on mainline
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPCAPPP_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/pcapplusplus)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
