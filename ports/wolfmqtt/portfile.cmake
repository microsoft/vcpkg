vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfssl/wolfmqtt
    REF v1.13.0
    SHA512 2bd05471c548bacf6fc5166d9c2ee546b3ce5c4fab89ff16175de9ab7696b8b570cdd7d4377378fc0cb579447488dbf727cb938192eb3180ed007414cb949a8a
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
