vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rdbo/libmem
    REF "${VERSION}"
    SHA512 a3245fedb0447133a674dc39b3f9dc0bce86cb8ed775cb50bc3b58ee410632653cfc340d17c2ca0a914e51ade9b62f393e23feb5f3d0459b1a1a8ce690a0d025
    HEAD_REF master
    PATCHES
        0001-CMakeLists.patch
)
file(REMOVE "${SOURCE_PATH}/PreLoad.cmake")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/libmem-config.cmake.in" DESTINATION "${SOURCE_PATH}")
vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
