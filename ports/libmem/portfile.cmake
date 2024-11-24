vcpkg_download_distfile(
    EXPORT_SURFACE_PATCH
    URLS https://github.com/rdbo/libmem/commit/04830fb5a6dd6c81843c1b54bd61dac5bd202b9a.patch?full_index=1
    FILENAME libmem-export-surface-04830fb5a6dd6c81843c1b54bd61dac5bd202b9a.patch
    SHA512 9060f86514f866a24a61b6cd51ee524f169b23781969b5f47f6fa5d2144369e7648658848fb2e00e9f0aed72119c4ab20842ba5afe9b0a485eea15ff63934596
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rdbo/libmem
    REF ${VERSION}
    SHA512 d7c5a1a42d65a00ed3aa8ba8f6974650801d3436ae90e072fea29d4dcb32a3963e2610c89a16b87d94a9613c8f2f0e8deb83b673a1771a9cd1eb716a56106a16
    HEAD_REF master
    PATCHES
        0001-CMakeLists.patch
        "${EXPORT_SURFACE_PATCH}"
)

message(WARNING "Removing PreLoad.cmake")
file(REMOVE "${SOURCE_PATH}/PreLoad.cmake")

file(MAKE_DIRECTORY "${SOURCE_PATH}/cmake")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/libmem-config.cmake.in" 
    DESTINATION "${SOURCE_PATH}"
)

vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
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
