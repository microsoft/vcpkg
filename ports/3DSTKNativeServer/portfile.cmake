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

message(WARNING "3D Streaming Toolkit only works on Windows. As such, this build will fail on any other OS.")

include(vcpkg_common_functions)

set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CMAKE_SYSTEM_NAME "")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)

vcpkg_download_distfile(ARCHIVE
   URLS https://github.com/CatalystCode/3DStreamingToolkit/archive/v2.0.tar.gz
   FILENAME "v2.0.tar.gz"
   SHA512 e0b5cc82b2061b4bf976e5d15342005a60dd671ba50d86a3094be028447dc1a66e46f4e26dba97a00781afc0257f0401378bbfd0f45dc447e428388f773d1b1a
)

vcpkg_extract_source_archive(${ARCHIVE})

set(TOOLKIT_PATH ${SOURCE_PATH}/3DStreamingToolkit-2.0)

execute_process(
    COMMAND powershell.exe -ExecutionPolicy Bypass ${TOOLKIT_PATH}/Utilities/setup.ps1
    WORKING_DIRECTORY ${TOOLKIT_PATH}
)

vcpkg_build_msbuild(
    PROJECT_PATH ${TOOLKIT_PATH}/Plugins/NativeServerPlugin/StreamingNativeServerPlugin.sln
)

file(COPY ${TOOLKIT_PATH}/Plugins/NativeServerPlugin/inc
    DESTINATION ${CURRENT_PACKAGES_DIR}
)

file(RENAME ${CURRENT_PACKAGES_DIR}/inc ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
file(INSTALL ${TOOLKIT_PATH}/LICENSE 
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/3DSTKNativeServer
    RENAME copyright
)
