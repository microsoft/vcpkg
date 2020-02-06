include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.lua.org/ftp/lua-5.3.5.tar.gz"
    FILENAME "lua-5.3.5.tar.gz"
    SHA512 4f9516acc4659dfd0a9e911bfa00c0788f0ad9348e5724fe8fb17aac59e9c0060a64378f82be86f8534e49c6c013e7488ad17321bafcc787831d3d67406bd0f4
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES vs2015-impl-c99.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCOMPILE_AS_CPP=OFF
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
        -DSKIP_INSTALL_TOOLS=ON
)

vcpkg_install_cmake()

if("cpp" IN_LIST FEATURES)
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS
            -DCOMPILE_AS_CPP=ON
        OPTIONS_DEBUG
            -DSKIP_INSTALL_HEADERS=ON
            -DSKIP_INSTALL_TOOLS=ON
    )

    vcpkg_install_cmake()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
        file(READ ${CURRENT_PACKAGES_DIR}/include/luaconf.h LUA_CONF_H)
        string(REPLACE "defined(LUA_BUILD_AS_DLL)" "1" LUA_CONF_H "${LUA_CONF_H}")
        file(WRITE ${CURRENT_PACKAGES_DIR}/include/luaconf.h "${LUA_CONF_H}")
    endif()
endif()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/lua)

# Handle copyright
file(COPY ${CMAKE_CURRENT_LIST_DIR}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/lua/copyright)
# Copy post-build CMake instructions
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/lua)
vcpkg_copy_pdbs()
