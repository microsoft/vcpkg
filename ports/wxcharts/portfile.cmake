vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wxIshiko/wxCharts
    REF c7c7eb4c4132eeb83f25546b1b981dc61e5c188f
    SHA512 f46cf467b356e2ffa46db020de42f8aca9beab801e2ade50f7e75650bba9bc83c641702dcd5ee45e82425b96d4371b82e7f16dce3077050a86ba696ed5c326de
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)