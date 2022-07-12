vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  inie0722/CTL
    REF v1.1.2
    SHA512 5669db0448359023cc55b0f9134084cda3aea716996d58ef7e8e63d3721c074af27f59a52c1976c72decea93630f64c463718344f34fdae3e5a832c9d876913a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
