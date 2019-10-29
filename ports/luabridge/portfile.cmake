include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vinniefalco/LuaBridge
    REF 78ab57abf2f76bf20f76a3bbc7dae7a1754a02c7 # 2.4.1
    SHA512 b53544cd544e9939e6e5f32a2b88f603a94fcbbf344b14b08f9e677c8e01c4e4185c0cecca0513449c9488a741e93285150156a96d633c8e54762b503b8999b4
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
