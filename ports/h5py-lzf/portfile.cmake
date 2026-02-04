vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO h5py/h5py
    REF ${VERSION}
    SHA512 6e63113223698c69e5c3c8214e07dce39872ee815ec15d3a217b9d9275463a3ca238c7375d6c566dd1079e937ae747b4af8f9302cac7b3019559bf149d7b6628
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
