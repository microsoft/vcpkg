vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO EmmyLua/EmmyLuaDebugger
    REF 1.8.7
    SHA512 d697d0ea12ca24c4f692e8104f75f681b7c56635459f6af437064e0e45b5b1cde5480817a7bd2de98555ffe6ef42712c3797e7dfd807425bfa095e0780a8fb5e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DEMMY_LUA_VERSION=54
)

vcpkg_cmake_install()

# Install any built tools/executables
vcpkg_copy_tools(AUTO_CLEAN)

# Install includes if they exist
if(EXISTS "${SOURCE_PATH}/include")
    file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
endif()

# Remove debug includes
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/copyright")

# Fix pkg-config files if present
vcpkg_fixup_pkgconfig()