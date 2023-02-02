vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gknowles/dimcli
    REF v7.1.0
    SHA512 3fad1c68e116c65df453a545fe9def6dc05941675900fd81728531d7638fc1814b82ee1f613ec451bc6c31702a3d5e31f275e605fe6bd62c61513ecd78a172cc
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" staticCrt)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DLINK_STATIC_RUNTIME:BOOL=${staticCrt}
        -DINSTALL_LIBS:BOOL=ON
        -DBUILD_PROJECT_NAME=dimcli
        -DBUILD_TESTING=OFF
        -DINSTALL_TOOLS=OFF
        -DINSTALL_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Remove includes from ${CMAKE_INSTALL_PREFIX}/debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/dimcli" RENAME copyright)
