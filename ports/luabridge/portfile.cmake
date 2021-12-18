vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vinniefalco/LuaBridge
    REF 12d51bdd992a22b43adb9cc5fb83ebf8b1f2be7f # 2.6
    SHA512 18593b2fda5be0b7cd9701feed53820002f93bba883cfa9fcdfa3e25ead02fb9b2f16f30d1603ae5d43ee3b199925071260723d4ebb79eb581888496d422f42d
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
