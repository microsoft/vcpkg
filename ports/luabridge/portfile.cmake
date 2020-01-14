include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vinniefalco/LuaBridge
    REF b6f17446265865e0ba06bea4d8e328eebfa2b9f0
    SHA512 a422489826ae7047a794948b315f1f9abf8a3201da1d2bf31212a0fd24f47e7a86f17803b1dc678dfc1e0f6724c8e5333bea1a5c7d1e4814e59604cebaa311da
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
