vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfssl/wolfmqtt
    REF "v${VERSION}"
    SHA512 354ab619144bd29258e65bd06219dddb4c89d5709c3246d6968239ab29426fb3882f2d5acad866cc431f6164c5e41b7da3a24ab7923fabc27deafd2801b92580
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
