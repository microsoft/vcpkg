if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

# Convert PcapPlusPlus to add leading zero 23.9 => 23.09
string(REGEX REPLACE "^([0-9]+)[.]([0-9])\$" "\\1.0\\2" PCAPPLUSPLUS_VERSION "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO seladb/PcapPlusPlus
    REF "v${PCAPPLUSPLUS_VERSION}"
    SHA512 06c1440a7f88cbef13e5cd2bfbd3c2c1be73f859fc778a25760e0af9ff988b2814a0888d6fadbb3771dfc155dacda5860aa865d8ec5f2cf348d1a1aa29d1cdf4
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPCAPPP_BUILD_EXAMPLES=OFF
        -DPCAPPP_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/pcapplusplus)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
