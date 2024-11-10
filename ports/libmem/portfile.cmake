vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rdbo/libmem
    REF ${VERSION}
    SHA512 d7c5a1a42d65a00ed3aa8ba8f6974650801d3436ae90e072fea29d4dcb32a3963e2610c89a16b87d94a9613c8f2f0e8deb83b673a1771a9cd1eb716a56106a16
    HEAD_REF master
    PATCHES
        libmem-h.patch
        libmem-hpp.patch
        api-h.patch
        0001-CMakeLists.patch
)

message(WARNING "Removing PreLoad.cmake")
file(REMOVE "${SOURCE_PATH}/PreLoad.cmake")

file(MAKE_DIRECTORY "${SOURCE_PATH}/cmake")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/libmem-config.cmake.in" 
    DESTINATION "${SOURCE_PATH}"
)

vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
