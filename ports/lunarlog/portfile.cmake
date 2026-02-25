vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LunarECL/LunarLog
    REF "v1.29.1"
    SHA512 07e479734568ebf7dd00f3e7d9dbc3d359fa3c1fe7270440aa719f7ee48904a5556e97397195398ada3375b1c7e0e5b289dccabb0ec82e362e7010fd441450a9
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLUNARLOG_BUILD_TESTS=OFF
        -DLUNARLOG_BUILD_EXAMPLES=OFF
        -DLUNARLOG_BUILD_BENCHMARKS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/LunarLog)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
