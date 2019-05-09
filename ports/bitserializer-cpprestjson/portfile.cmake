include(vcpkg_common_functions)
vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Pavel_Kisliak/BitSerializer
	REF 0.8
	SHA512 6df5b3f7a472a55ba0aace22c44cb2adaf178fbc7f920dcaf7d7015f81badde98d64911ddb620e99a708214140d7c29561775c1b0fe60fef6f24d465a4eac093
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/archives/bitserializer_cpprest_json DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/bitserializer-cpprestjson RENAME copyright)
