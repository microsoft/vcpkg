vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uriparser/uriparser
    REF 25dddb16cf044a7df27884e7ad3911baaaca3d7c # uriparser-0.9.4
    SHA512 9001649eb027d0ff4f990b20d0f05643939e2bb8ab89d158f32353d6f7c4264a551a6af7856ad13890d05f58b3d15d59e6d82ee0d95b7788c03b34bb52086cd2
    HEAD_REF master
)

if("tool" IN_LIST FEATURES)
    set(URIPARSER_BUILD_TOOLS ON)
else()
    set(URIPARSER_BUILD_TOOLS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DURIPARSER_BUILD_DOCS=OFF
        -DURIPARSER_BUILD_TESTS=OFF
    OPTIONS_DEBUG
        -DURIPARSER_BUILD_TOOLS=OFF
    OPTIONS_RELEASE
        -DURIPARSER_BUILD_TOOLS=${URIPARSER_BUILD_TOOLS}
)

vcpkg_install_cmake()

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

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT}-${_package_version})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/include/uriparser/UriBase.h
        "defined(URI_STATIC_BUILD)"
        "1 // defined(URI_STATIC_BUILD)"
    )
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/uriparser RENAME copyright)

# Remove duplicate info
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
