include(vcpkg_common_functions)
vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Pavel_Kisliak/BitSerializer
	REF 0.7
	SHA512 3a50b1b3077115f60d298f4257ae6a5a350c1d8b3d575af83b4f0746757ab3393da7c81ac9c7db4e30540fe94f1742b1d39de724b2dec080faf727b885bb19a4
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/bitserializer RENAME copyright)
