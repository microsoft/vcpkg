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
    REPO smlee-hdactech/json_spirit
    REF 28d747f0be5c2f2f8cbfb9a01a2d6d560eec6c80
    SHA512 ec52a8ca78d294d85a0f3c81272f62e15d0cfc363f9fba4730705ab0b0c14ce38eb11da0ebc9ccba07ecda0ba8944d20aa55bcd907c803e3995d462bb06e0745
    HEAD_REF master
)

#set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/json_spirit-4.1.0)
#vcpkg_download_distfile(ARCHIVE
#    URLS "https://github.com/smlee-hdactech/json_spirit/archive/v4.1.0.zip"
#    FILENAME "json-spirit-4.1.0.zip"
#    SHA512 84e4f2db15db673814ec088e0621cd3b5667543660f68eeab9fe3e9dac8d48e5894c6678468dfa98848655f4348ac5263b019ec124af0e52cd2332f05bc20514
#)
#vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/json-spirit RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME json-spirit)
