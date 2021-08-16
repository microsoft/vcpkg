vcpkg_download_distfile(ARCHIVE
    URLS "https://www.lua.org/ftp/lua-5.4.3.tar.gz"
    FILENAME "lua-5.4.3.tar.gz"
    SHA512 3a1a3ee8694b72b4ec9d3ce76705fe179328294353604ca950c53f41b41161b449877d43318ef4501fee44ecbd6c83314ce7468d7425ba9b2903c9c32a28bbc0
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        vs2015-impl-c99.patch
        fix-ios-system.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

# Used in cmake wrapper
set(ENABLE_LUA_CPP 0)
if ("cpp" IN_LIST FEATURES)
    set(ENABLE_LUA_CPP 1)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    cpp COMPILE_AS_CPP
    tools INSTALL_TOOLS
)
if(VCPKG_TARGET_IS_IOS AND "tools" IN_LIST FEATURES)
    message(FATAL_ERROR "lua[tools] is not supported for iOS platform build")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
         ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)
vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-lua TARGET_PATH share/unofficial-lua)

if("cpp" IN_LIST FEATURES)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-lua-cpp TARGET_PATH share/unofficial-lua-cpp)
endif()

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES lua luac SEARCH_DIR "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    if(VCPKG_TARGET_IS_WINDOWS)
        file(READ ${CURRENT_PACKAGES_DIR}/include/luaconf.h LUA_CONF_H)
        string(REPLACE "defined(LUA_BUILD_AS_DLL)" "1" LUA_CONF_H "${LUA_CONF_H}")
        file(WRITE ${CURRENT_PACKAGES_DIR}/include/luaconf.h "${LUA_CONF_H}")
    endif()
endif()

# Suitable for old version
configure_file(${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in  ${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake @ONLY)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Handle copyright
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
