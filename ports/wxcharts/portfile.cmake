vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wxIshiko/wxCharts
    REF 070e1d6084623185c7337226fa562b1e3a772e3d
    SHA512 4c52e4ad6d3c4ba496aad7e654ee75ddd9009aadc44be37fc64f3e3ac56001a7e9728f7fdd0c78f8261bff0bf8a6748f8a7649cb160ca37c2d686530c161c2f6
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)