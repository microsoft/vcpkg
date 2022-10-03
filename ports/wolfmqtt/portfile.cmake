vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfssl/wolfmqtt
    REF v1.14.1
    SHA512 ea7657e1c5045996c24bf479fc0c2db7d7d3f588e998d4d236f9d5d43564f80a1fa8ec0710bf87d7b785ffb29d96d539e5b7e7bea5574f0c3843dc00062dbb11
    HEAD_REF master
    PATCHES
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
