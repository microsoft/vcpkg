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

#set (VCPKG_LIBRARY_LINKAGE dynamic)
include(vcpkg_common_functions)
#vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # don't use shared libs
set( LIBNOISE_VERSION "1.0.0" )
set( LIBNOISE_COMMIT "d7e68784a2b24c632868506780eba336ede74ecd" )

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RobertHue/libnoise
    REF ${LIBNOISE_COMMIT}
    SHA512 8c4d654acb4ae3d90ee62ebdf0447f876022dcb887ebfad88f39b09d29183a58e6fc1b1f1d03edff804975c8befcc6eda33c44797495285aae338c2e869a14d7
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
