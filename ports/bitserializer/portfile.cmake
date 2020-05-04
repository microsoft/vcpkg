vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Pavel_Kisliak/BitSerializer
	REF 0.9
	SHA512 74515a1a8338935c52752200d96abc0c0ee2c2b0b42880b1d10c8f56b5f8eb30680bd96b64eb2b352764128ad6a1fcd59749f481883c48a06230d652bee05902
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/core
    PREFER_NINJA
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/bitserializer/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
