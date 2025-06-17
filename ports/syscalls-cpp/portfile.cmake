vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sapdragon/syscalls-cpp
    REF "v${VERSION}"             
    SHA512 4dd8afa32367f4624f56308eb846b38b854df7fe619cb504c10173933969d7b849b6b0ae760650f11fdbdbc3fe3240477fb505efd64fae4c780428f3b68440ef
    HEAD_REF main                
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME syscalls-cpp)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")