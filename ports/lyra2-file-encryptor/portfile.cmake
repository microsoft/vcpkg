vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO amazon-biobank/lyra2-file-encryptor
    REF e5cf962633f6a0a7acd3f3adf4fcbf10f014e6bf
    SHA512 e750d5530cd5c14f2dc61f5abf8ee1e34884c12d5f39e0cbad623aa72a842efaa9b2fd0728ed64ee4bc6f2b0299dcea9e6ea23f59cb1826e1577cdf5158e8009    
    HEAD_REF V_1_2
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake/lyra2-file-encryptor)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)