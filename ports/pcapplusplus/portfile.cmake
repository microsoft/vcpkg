if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

# Convert PcapPlusPlus to add leading zero 23.9 => 23.09
string(REGEX REPLACE "^([0-9]+)[.]([0-9])\$" "\\1.0\\2" PCAPPLUSPLUS_VERSION "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO seladb/PcapPlusPlus
    REF "v${PCAPPLUSPLUS_VERSION}"
    SHA512 e7dc1dbd85c9f0d2f9c5d3e436456c2cd183fb508c869fa8fb83f46aac99b868a16283204e5d57a0bfd7587f6ac2582b3e14c6098683fad4501708c8fededd6a
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
