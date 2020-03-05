vcpkg_fail_port_install(ON_TARGET "UWP" "Windows")

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO powturbo/Turbo-Base64
        REF 5257626d2be17a3eb23f79be17fe55ebba394ad2
        SHA512 7843652793d20c007178cd2069f376578d39566f6e558d7a2ea4f453046ebf5729e7208d6aca205fcca4d2174a3c4de3a6bc841d455778ebf95b3bdaad08c399
        HEAD_REF master
)

configure_file(${CURRENT_PORT_DIR}/CMakeLists.txt ${SOURCE_PATH}/CMakeLists.txt COPYONLY)

vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
