vcpkg_fail_port_install(ON_TARGET "Windows" "OSX")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-lambda-cpp
    REF 681652d9410bb4adb66e5afa9e8a3662a5f7b606 # v0.2.4
    SHA512 c29ea2b8fb8b99a5d0a49f601406e14682e5133deeb871a750baa792becc91f22dac00c0ee3d8c056871a1f5035cdcd1a3bba3d9464dfa84e1ec00a270a9abd6
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

