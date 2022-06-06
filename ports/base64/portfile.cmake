vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aklomp/base64
    REF 9ae5ad37720bc94e90719566de48e2444b96b642
    SHA512 cbfa5faf3693603708a49744db7d1986aeb595e27f106e55a85213d808156ec89b69b06486c7add3514799ec1f51ccac02c47e5d50810f5b770945ad007c1a0a
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBASE64_BUILD_CLI=OFF
        -DCMAKE_INSTALL_INCLUDEDIR="${CURRENT_PACKAGES_DIR}/include"
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/base64)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
