vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/sparse-map
    REF d71e6fd75f4970f07f4f1fe67438055be70d0945 # v0.6.2
    SHA512 ad270be66b3d5f96cb0305f0e086807aee1c909dd022c19ca99e5f7a72d5116f2ecb4b67fcb80e8bdb4f98925387d95bdc0bcc450a10b97c61f9b92c681f95b5
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/LICENSE 
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} 
     RENAME copyright
)
