# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kunitoki/LuaBridge3
    REF 3b5ccfb2331cecc4b1b9e8b8ccccb4bf5ce0a304 # 3.0
    SHA512 01656f78532c7d2d39320ec0e64527da8233aad3a8fded45809c14c1186ec24a354efc476f4ec51e3d3d6c47a4e0500b56001b55d263da8e1863e484c6cc11fe
    HEAD_REF master
)

file(
    COPY ${SOURCE_PATH}/Source/LuaBridge
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/{PORT}
)

# Handle copyright
configure_file(
    ${SOURCE_PATH}/LICENSE.txt
    ${CURRENT_PACKAGES_DIR}/share/luabridge/copyright
    COPYONLY
)
