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

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)

#vcpkg_download_distfile(ARCHIVE
#    URLS "https://github.com/CatalystCode/3DStreamingToolkit/archive/v1.0.tar.gz"
#    FILENAME "v1.0.tar.gz"
#    SHA512 344ca5199965a01d53874df41cf4d1f7010e7f7240abd65237d2444fc5146fa20bbd89233c268598ab907f10b1f1a0a5331631ea7023c27832d640baa06cb41a
#)

#vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CatalystCode/3DStreamingToolkit
    REF 56afbb5d97da14e5422a9aea50fed1ad34a7e1b4
    SHA512 538d79bf218c73f77e2e14a37131a7a341512ad80417b13802534fb09b464815ebb900cba141b084a412501277a06537f4b7107cb7e3ba1d06d2ba476ef8f462
    HEAD_REF master 
)

execute_process(
    COMMAND powershell.exe -ExecutionPolicy Bypass ${SOURCE_PATH}/Utilities/setup.ps1
    WORKING_DIRECTORY ${SOURCE_PATH}
    
)

vcpkg_build_msbuild(
    PROJECT_PATH ${CURRENT_BUILDTREES_DIR}/src/3DStreamingToolkit-1.0/Plugins/NativeServerPlugin/StreamingNativeServerPlugin.sln
    PLATFORM x64
)

# Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/3DSTKNativeServer RENAME copyright)
