vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Soundux/lockpp
    REF 3af2d0b4a249cfb723ef2f37d2fd1fff8cecae24
    SHA512 78e015705e33bb6fc262ecb56bee213d29c63b3ed9ce14f495534cfb7325146d202b7247157f980e70d37b020374c52c263adbd22b790e520c8889bdb83b01ca
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
