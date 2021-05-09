vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO amazon-biobank/lyra2-file-encryptor
    REF b0ce886ed506eeaa37cd54be1578d784b1a37d0c
    SHA512 55e6b73c3f45dc678cbdfd212b12c53c36b20bc29fab21cf143aa5248feb672c54fe3a6597e01266227ef46bd47a35e8b2c844623d078ff7c5c89116dfb8760c    
    HEAD_REF V_1_2
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake/Lyra2FileEncryptor)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)