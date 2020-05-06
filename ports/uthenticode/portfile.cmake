vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO trailofbits/uthenticode
    REF v1.0.1
    SHA512 a20137c82b7a5cf7fd16ea2f4bf460fc515d159e93d905fc80d9732bb05850953369a29a586d4b3435f348dc5883cf3a084f1445364c63468dd4149e8c90b20c
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/uthenticode TARGET_PATH share/uthenticode)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(
    INSTALL
    "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/uthenticode"
    RENAME copyright
)
