vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rdbo/libmem
    REF "${VERSION}"
    SHA512 fb953952c1d11d453ab290b0e3af38ebb24e81fcfeb62b0f8fb7a50e1de2304c2116278b8fefe885708d2705239be2c92bb592cbe912e5fcb0dbf83e5de529f4
    HEAD_REF master
    PATCHES
        0001-CMakeLists.patch
)
file(REMOVE "${SOURCE_PATH}/PreLoad.cmake")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/libmem-config.cmake.in" DESTINATION "${SOURCE_PATH}")
vcpkg_find_acquire_program(PKGCONFIG)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LIBMEM_BUILD_STATIC)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVERSION=${VERSION}
        -DLIBMEM_BUILD_TESTS=OFF
        -DLIBMEM_DEEP_TESTS=OFF
        -DLIBMEM_BUILD_STATIC=${LIBMEM_BUILD_STATIC}
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
