if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

# Convert PcapPlusPlus to add leading zero 23.9 => 23.09
string(REGEX REPLACE "^([0-9]+)[.]([0-9])\$" "\\1.0\\2" PCAPPLUSPLUS_VERSION "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO seladb/PcapPlusPlus
    REF "v${PCAPPLUSPLUS_VERSION}"
    SHA512 83f95e82cbbd10a88b6d333d2b6c6f1e4fef8b0b86f8ad6202cf77d50bf7a1c6afdcb0254962c37cc1c4b55e2e9700b97cc6222129990ff86fcefc7b06621cd0
    HEAD_REF master
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
