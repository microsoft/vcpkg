vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "linux" "uwp" "osx")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux
    REF 9e971731ec8c50425754af030fbe16ec603c3d22 # v1.6.0
    SHA512 2e689b4e1ffc2f5e472e0ee8c87857336b4e049969600c82c8f576e2c82939d65658bb6ef62fbe751c03b92f6f14d1b9bcf7a085d2848c0556e3039a5906261d
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
