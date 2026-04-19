vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IPGeolocation/ip-geolocation-api-cpp-sdk
    REF v1.0.0
    SHA512 546be6ee2f51a0a2e9c7a5fa6940cee21238277a5802ab0599b5a7e56f9f8e38c6b8e275efbf4c06a5bc89487e09e70268d6b63ea45088365abc1089e9c70c1c
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DIPGEOLOCATION_BUILD_TESTS=OFF
        -DIPGEOLOCATION_ENABLE_COVERAGE=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/ipgeolocation")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
