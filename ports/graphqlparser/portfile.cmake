# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO graphql/libgraphqlparser
    REF v0.7.0
    SHA512 973292b164d0d2cfe453a2f01559dbdb1b9d22b6304f6a3aabf71e2c0a3e24ab69dfd72a086764ad5befecf0005620f8e86f552dacc324f9615a05f31de7cede
    HEAD_REF master
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/win-cmake.patch
)

if(UNIX)
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
    )
elseif(WIN32)
    vcpkg_find_acquire_program(PYTHON2)
    vcpkg_find_acquire_program(FLEX)
    vcpkg_find_acquire_program(BISON)

    get_filename_component(VCPKG_DOWNLOADS_PYTHON2_DIR "${PYTHON2}" DIRECTORY)
    get_filename_component(VCPKG_DOWNLOADS_FLEX_DIR "${FLEX}" DIRECTORY)
    get_filename_component(VCPKG_DOWNLOADS_BISON_DIR "${BISON}" DIRECTORY)

    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS
            -DVCPKG_DOWNLOADS_PYTHON2_DIR=${VCPKG_DOWNLOADS_PYTHON2_DIR}
            -DVCPKG_DOWNLOADS_FLEX_DIR=${VCPKG_DOWNLOADS_FLEX_DIR}
            -DVCPKG_DOWNLOADS_BISON_DIR=${VCPKG_DOWNLOADS_BISON_DIR}
    )
endif()

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/graphqlparser RENAME copyright)
