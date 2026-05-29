vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO itas109/CSerialPort
    REF "v${VERSION}"
    SHA512 657d0696df97d71d8b44f5e254e72ca1c36d701e84284d78e8bb6d4f5b525920e192477009cc79137984563dbd9d30ae530407dbcd121a5171326e0012a1a3f5
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
