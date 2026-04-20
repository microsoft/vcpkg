vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IPGeolocation/ip-geolocation-api-cpp-sdk
    REF v1.0.0
    SHA512 92417a1b1d543952b063e0c7e23aa907efbe921411ea042a8300c00a2046c7a65daf2a5912e886067ee8ef417390879b1765566f36f0a7f2390941277f9354ec
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
