vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice/idevicerestore
    REF 609f7f058487596597e8e742088119fdd46729df # commits on 2023-05-23
    SHA512 9427c438d1967f1717424dd1d1b789d3d139b3fcacee15911e531d6377039927c147150dafacd251b92d57134e72c49de6e1a053fcd63f14c780e60dc5b13fc5
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_tools(TOOL_NAMES idevicerestore AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
