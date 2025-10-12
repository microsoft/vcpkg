vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rdbo/libmem
    REF "${VERSION}"
    SHA512 ee231e5ae7ed08f2e9950ee2d6604ed29a777d816a057b6451953cb03eb52579a73c3e77b9af059963223486798bf73ea7e2f579c7e9d1e222091125b3e1eeee
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
