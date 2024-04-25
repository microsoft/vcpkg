vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO h5py/h5py
    REF a6555f787e110b29af654ba6c350169c44ac8d2d
    SHA512 1d601b499a6ccdcc5dd473b235d915b85501476ca3e9343d6f6f624a8eeb5acbeced227ec552a12936451a438d0c1f25c1d974549e80aaa724646b5bdb9ae20c
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
