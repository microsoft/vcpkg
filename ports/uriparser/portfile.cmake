vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uriparser/uriparser
    REF 092c2ed1c1cdf2e3305f76927369a07b294eb279 # uriparser-0.9.5
    SHA512 2d7a4e9d186389bada2a8e6b4400b628ea54d17fb8d8ba32f2f416205480a72e94c724ba04462b874b3b4b9399b7f776bcfae76a8cb96a8b896514c05d2be775
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
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/config.h"
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
