vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uriparser/uriparser
    REF uriparser-${VERSION}
    SHA512 4222e6d7dcdb525514ca8f42e5a9b314e0f09102ef2e72131702b6297d7cb9f509f757b9bec64c4ef88146667a60b992ff71e3c1fea50a82e45c3a14b8992326
    HEAD_REF master
)

if("tool" IN_LIST FEATURES)
    set(URIPARSER_BUILD_TOOLS ON)
else()
    set(URIPARSER_BUILD_TOOLS OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DURIPARSER_BUILD_DOCS=OFF
        -DURIPARSER_BUILD_TESTS=OFF
    OPTIONS_DEBUG
        -DURIPARSER_BUILD_TOOLS=OFF
    OPTIONS_RELEASE
        -DURIPARSER_BUILD_TOOLS=${URIPARSER_BUILD_TOOLS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

if(URIPARSER_BUILD_TOOLS)
    vcpkg_copy_tools(
        TOOL_NAMES uriparse
        AUTO_CLEAN
    )
endif()

set(_package_version_re "#define[ ]+PACKAGE_VERSION[ ]+\"([0-9]+.[0-9]+.[0-9]+)\"")
file(STRINGS
	"${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/UriConfig.h"
    _package_version_define REGEX "${_package_version_re}"
)
string(REGEX REPLACE "${_package_version_re}" "\\1" _package_version ${_package_version_define})

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT}-${_package_version})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/uriparser/UriBase.h"
        "defined(URI_STATIC_BUILD)"
        "1 // defined(URI_STATIC_BUILD)"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_fixup_pkgconfig()
