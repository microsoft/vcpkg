vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO modelon-community/fmi-library
    REF "${VERSION}"
    SHA512 65c2dc11116737e4e2ee91a4ec58d2cf24003774fd6d9b8b1d6521f046be9e8f8a963ebedb50a161ad264927062f41ce757c84563cfe628d47614910e8730349
    HEAD_REF master
    PATCHES
        devendor-sublibs.diff
        minizip.patch
        fix-mergestaticlibs.diff
        unofficial-export.diff
)

file(GLOB vendored_minizip "${SOURCE_PATH}/ThirdParty/Minizip/minizip/*")
list(FILTER vendored_minizip EXCLUDE REGEX "/minizip.[ch]\$|/miniunz.[ch]\$")
file(REMOVE_RECURSE
    ${vendored_minizip}
    "${SOURCE_PATH}/ThirdParty/Expat"
    "${SOURCE_PATH}/ThirdParty/Zlib"
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" FMILIB_BUILD_WITH_STATIC_RTLIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Wno-dev
        -DFMILIB_BUILD_TESTS=OFF
        -DFMILIB_BUILD_STATIC_LIB=${BUILD_STATIC}
        -DFMILIB_BUILD_SHARED_LIB=${BUILD_SHARED}
        -DFMILIB_BUILD_WITH_STATIC_RTLIB=${FMILIB_BUILD_WITH_STATIC_RTLIB}
        -DFMILIB_GENERATE_DOXYGEN_DOC=OFF
    OPTIONS_DEBUG
        "-DFMILIB_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug"
    OPTIONS_RELEASE
        "-DFMILIB_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}"
    MAYBE_UNUSED_VARIABLES
        FMILIB_BUILD_WITH_STATIC_RTLIB
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-fmilib-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-fmilib")
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-fmilib)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/doc"
    "${CURRENT_PACKAGES_DIR}/doc"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
