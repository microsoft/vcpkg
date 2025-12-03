vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO moehoshio/NekoNetwork
    REF v1.0.1
    SHA512 367b836c255234352b270253b8bde4f781ca317d16e019741eabacd0ca86941a2be95f8e94a1a04eaa9bd58ace83b26da862d935ef03c5ed1ceabac310812cf8
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNEKO_NETWORK_BUILD_TESTS=OFF
        -DNEKO_NETWORK_AUTO_FETCH_DEPS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/NekoNetwork PACKAGE_NAME nekonetwork)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
