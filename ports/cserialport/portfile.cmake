vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO itas109/CSerialPort
    REF v4.3.0
    SHA512 dfe8eff2c78e06667c5de638d9fb688a42d473037415244f5f3a13b875604439447844bb12106a47d81155f05867b3d7c01577ee1942cf6af255a997c40954f8
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
