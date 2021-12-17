# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brunocodutra/metal
    REF 2.1.3
    SHA512 7a71f8bdbdb8a19084d0cabd4c78a4f2990514f2da56312aec8dfac02f6781c95f28bc33815ecbb3d9e3e8d2b47cc5dbcd4917751195a8318bea7c08fca29b23
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME Metal
    CONFIG_PATH lib/cmake/Metal
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
