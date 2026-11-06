vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfssl/wolfmqtt
    REF "v${VERSION}"
    SHA512 e4dcddde24bb3506c744803d6f613f62d88f9797c6c159cd440d9801a1cba1d471034eb3707e60d4d1b049da55c8fe23145352cd2d7e37ea0bbf333002a80513
    HEAD_REF master
    )

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
      -DWOLFMQTT_BUILD_OUT_OF_TREE=yes
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
