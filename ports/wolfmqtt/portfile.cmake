vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfssl/wolfmqtt
    REF v1.15.0
    SHA512 9012e4723d469ce98bd5f0e6a3e001ab6c94c0fb4fef0d2de73446d702959052f6f5fe5a9d805b088f17c2d94a25abf41ae802421c99b62f8d8cd9a14c9e7271
    HEAD_REF master
    )

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
      -DWOLFMQTT_EXAMPLES=no
    OPTIONS_DEBUG
      -DCMAKE_C_FLAGS='-DDEBUG_MQTT'
    )


vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/wolfmqtt)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
