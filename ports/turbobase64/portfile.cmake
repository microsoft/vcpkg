vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO powturbo/Turbo-Base64
        REF 95ba56a9b041f9933f5cd2bbb2ee4e083468c20a
        SHA512 bacab8ede5e20974207e01c13a93e6d8afc8d08bc84f1da2b6efa1b4d17408cef6cea085e209a8b7d3b2e2a7223a785f8c76aa954c3c787e9b8d891880b63606
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
