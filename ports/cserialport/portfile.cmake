vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO itas109/CSerialPort
    REF v4.2.1
    SHA512 a5d30ab1a970a1989b9295d37285a5043946164910b9ed455661b96e0b42a9d9c71d7ea9d23bbe3dc5d1c2f33ff0265320e0bb3199243146ba2eeb263757335f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCSERIALPORT_BUILD_EXAMPLES=OFF
        -DCSERIALPORT_BUILD_TEST=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/CSerialPort)
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
