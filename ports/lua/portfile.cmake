# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/lua-5.3.4)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.lua.org/ftp/lua-5.3.4.tar.gz"
    FILENAME "lua-5.3.4.tar.gz"
    SHA512 739e31f82e6a60fa99910c2005e991b3a1e21339af52847f653cb190b30842054d189ca116ffcfdf9b36e07888c9ce5642b1dd2988cc7eff9f8789f9a2e34997
)
vcpkg_extract_source_archive(${ARCHIVE})

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

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(READ ${CURRENT_PACKAGES_DIR}/include/luaconf.h LUA_CONF_H)
    string(REPLACE "defined(LUA_BUILD_AS_DLL)" "1" LUA_CONF_H "${LUA_CONF_H}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/luaconf.h "${LUA_CONF_H}")
endif()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/lua)

# Handle copyright
file(COPY ${CMAKE_CURRENT_LIST_DIR}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/lua)
vcpkg_copy_pdbs()
