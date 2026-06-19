vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO h5py/h5py
    REF ${VERSION}
    SHA512 514832e49de43d79a8a0ae24ebd72e4d8ec04aa834d0af6f3cae9418d2e9a5cc0b613064af8cb745d3f3fb8f60cfe0b771066ecb57dc17df0e56839a15c87718
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/lzf/lzf")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/lzf")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/lzf"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-h5py-lzf)
file(COPY "${CURRENT_PORT_DIR}/unofficial-h5py-lzf-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-h5py-lzf")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/lzf/LICENSE.txt")
