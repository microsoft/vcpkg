include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vinniefalco/LuaBridge
    REF 2.1
    SHA512 062efda16fe43a02bcc757aaebba839e0ec72a9a3b7bf1e5bc1427a54d664a52197c8bcd4ac584f0d04cce812c0f078e257716e8bca016bcabda82c2c332ac04
    HEAD_REF master
)

file(
    COPY ${SOURCE_PATH}/Source/LuaBridge
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
configure_file(
    ${SOURCE_PATH}/README.md
    ${CURRENT_PACKAGES_DIR}/share/luabridge/copyright
    COPYONLY
)
