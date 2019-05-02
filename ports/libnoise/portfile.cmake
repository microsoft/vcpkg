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
#vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # don't use shared libs
set( LIBNOISE_VERSION "1.0.0" )
set( LIBNOISE_COMMIT "032caf6572707e3e3acd5e6a899a315d9ad78d8c" )

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qknight/libnoise
    REF ${LIBNOISE_COMMIT}
    SHA512 2418c4197e40ed120d386711e4890b80894acb67645a19b51e51ac5c94d5863e5c04fd72da9e3ca32a604d57417936045c3c2aa674c618db942d52d549d5adaf
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

message( STATUS "CURRENT_PACKAGES_DIR: " ${CURRENT_PACKAGES_DIR} )
message( STATUS "CURRENT_BUILDTREES_DIR: " ${CURRENT_BUILDTREES_DIR} )

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/libnoise)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libnoise/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/libnoise/copyright)


# Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libnoise RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME libnoise)
