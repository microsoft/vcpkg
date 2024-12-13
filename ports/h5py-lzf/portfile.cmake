vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO h5py/h5py
    REF ${VERSION}
    SHA512 d741b377605b2aef2847731ddb8bc9fc06eece0882ccc32b0f74e52a50ca217a9813298df77c6ae4a9eca3ed1148f58314746308d341fb58200a25dab3cbd5e2
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
