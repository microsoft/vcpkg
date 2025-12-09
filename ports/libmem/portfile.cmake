vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rdbo/libmem
    REF "${VERSION}"
    SHA512 e9e237a5b34727e076801e5542351867b412096830518b4fb09a218ce6ce1c475eb133c3c063040b85a59d590c98a2a3161b0d7ac8a10557615dae9e0ef9a4bf
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
