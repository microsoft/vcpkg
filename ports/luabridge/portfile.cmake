vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kunitoki/LuaBridge3
    REF 5c064d66d621fe7f23b3bcdfd3b7be452c984e8a #v3.0-beta1
    SHA512 b9abd953756ac115ceef5fb01cc710ae011aaa61a71213d5af9e5377a4a625c6a46d866d27f100dcbfd6591216955686503d199958237a396eb53b9ec7185a3f
    HEAD_REF master
    PATCHES
        fix-find_package.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLUABRIDGE_TESTING=ON
)

file(INSTALL "${SOURCE_PATH}/Source/LuaBridge" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
configure_file("${SOURCE_PATH}/README.md" "${CURRENT_PACKAGES_DIR}/share/luabridge/copyright" COPYONLY)
