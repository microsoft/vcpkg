vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uriparser/uriparser
    REF uriparser-${VERSION}
    SHA512 0ab98e3172d9767ec0a62018c70190efb5aec813c310e7305fb4ffeb187976734d35ba2f83f6ea0b3f390f13740491d9538e5960b93ca1bbb848a1fe41c559a3
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

file(INSTALL "${SOURCE_PATH}/COPYING.Apache-2.0" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/COPYING.BSD-3-Clause" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/COPYING.LGPL-2.1" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_fixup_pkgconfig()
