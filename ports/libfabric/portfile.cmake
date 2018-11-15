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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libfabric-1.6.2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ofiwg/libfabric/archive/v1.6.2.zip"
    FILENAME "libfabric-1.6.2.zip"
    SHA512 1a31546e4610beb9ae68ad2c42939ea363bd058bf6fa4260825fdc22489e22dea755648e78ae42bdd52238ac9ec0db93a848373ecded5813afc59fd6964dc348
)
vcpkg_extract_source_archive(${ARCHIVE})

if(TRIPLET_SYSTEM_ARCH MATCHES "x86")
   message(FATAL_ERROR "VCPKG BUILD ERROR: libfabric only supports x64")
elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
   message(FATAL_ERROR "VCPKG BUILD ERROR: libfabric only supports x64")
endif()

set(LIBFABRIC_RELEASE_CONFIGURATION "Release-v141")
set(LIBFABRIC_DEBUG_CONFIGURATION "Debug-v141")

#Set this variable to the path to your installation of NetworkDirect_DDK
#
#set(NETDIRECTDDK_PATH "")

if(NETDIRECTDDK_PATH STREQUAL "")
    message(FATAL_ERROR "Set variable 'NETDIRECTDDK_PATH' in directory '$VCPKG_ROOT/ports/libfabric/portfile.cmake' to the directory NetworkDirect_DDK.zip was decompressed into. NetworkDirect can be downloaded from nuget at https://www.nuget.org/packages/NetworkDirect or https://www.microsoft.com/en-us/download/details.aspx?id=36043")
else()
    file(INSTALL
        "${NETDIRECTDDK_PATH}/NetDirect/include/nddef.h"
        DESTINATION ${SOURCE_PATH}/prov/netdir/NetDirect
    )

    file(INSTALL
        "${NETDIRECTDDK_PATH}/NetDirect/include/ndioctl.h"
        DESTINATION ${SOURCE_PATH}/prov/netdir/NetDirect
    )

    file(INSTALL
        "${NETDIRECTDDK_PATH}/NetDirect/include/ndspi.h"
        DESTINATION ${SOURCE_PATH}/prov/netdir/NetDirect
    )

    file(INSTALL
        "${NETDIRECTDDK_PATH}/NetDirect/include/ndstatus.h"
        DESTINATION ${SOURCE_PATH}/prov/netdir/NetDirect
    )
endif()

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH libfabric.vcxproj
    INCLUDES_SUBPATH include
    LICENSE_SUBPATH COPYING
    PLATFORM "x64"
    RELEASE_CONFIGURATION ${LIBFABRIC_RELEASE_CONFIGURATION}
    DEBUG_CONFIGURATION ${LIBFABRIC_RELEASE_CONFIGURATION}
    USE_VCPKG_INTEGRATION
    ALLOW_ROOT_INCLUDES
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libfabric RENAME copyright)

# Post-build test for cmake libraries
 vcpkg_test_cmake(PACKAGE_NAME libfabric)
