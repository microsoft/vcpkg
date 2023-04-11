vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cwzx/nngpp
    REF cc5d2641babab165d8a9943817c46d36c6dc17c2 #v1.3.0
    SHA512 76b78f5b39b24fae3820924abb5c2f8f51f1683c08211366668745196b184ee4b4c9b1fd2fc68e8f234a56b802a4a79249d173d1562af46046d19a4498222405
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNNGPP_BUILD_DEMOS=OFF
        -DNNGPP_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

# Move CMake config files to the right place
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

