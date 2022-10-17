vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO itas109/CSerialPort
    REF v4.1.1
    SHA512 4e0b6d5d07ac9f213762a8bf6a90a109ec134b04a8645dc5fc0b89c69a798c857924ee37f13f421b421148bc39bf1ed4f37361e5d1d9f7f51e0faf01757b3927
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_SHARED_LIBS ON)
else()
    set(BUILD_SHARED_LIBS OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCSERIALPORT_BUILD_EXAMPLES=OFF
        -DCSERIALPORT_BUILD_TEST=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/CSerialPort)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/cserialport/copyright" COPYONLY)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_pkgconfig()
