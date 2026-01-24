vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rdbo/libmem
    REF "${VERSION}"
    SHA512 7b291fac0d12be6734cdf2be9705b787c0419aa45d3ce41a968f9e2a009eba739eadbf6ba1ea1663134b97eb20a97992af62fdb5157235d2b21ea76cc1f7f7fd
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
