vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SpartanJ/soil2
    REF ddcb35d13cc4129103de1c1a3cb74b828fe46b4a # 1.3.0
    SHA512 627c7bf4fddd5afef85ba7634c5ec0e10005c700abc1eb07c6346c1604e430c34aa4c33f6ffecbecb3dc2b04de7b855a3f6d923e94f23621ae0184e706358908
    HEAD_REF master
    PATCHES Workaround-ICE-in-release.patch
)

file(
    COPY 
    "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
    "${CMAKE_CURRENT_LIST_DIR}/soil2Config.cmake.in"
    DESTINATION "${SOURCE_PATH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_cmake_install()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
