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

set(ECSUtil_HASH c25095edf6975706356485314e3a3fcab924a45cd18b28744f62c8b8d6451a705fb37877ee778b1d9dc426e3bc80b4323fe8ba7fabd7d119d7fe245a55252e55)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)

#architecture detection
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
   set(ECSUtil_ARCH Win32)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
   set(ECSUtil_ARCH x64)
else()
   message(FATAL_ERROR "unsupported architecture")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(ECSUtil_CONFIGURATION_RELEASE Release)
    set(ECSUtil_CONFIGURATION_DEBUG Debug)
else()
    set(ECSUtil_CONFIGURATION_RELEASE "Release Lib Static")
    set(ECSUtil_CONFIGURATION_DEBUG "Debug Lib Static")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "http://kskskszlib.net/zlib-1.2.11.tar.gz"
    FILENAME "ecs-object-client-windows-cpp.zip"
    SHA512 ${ECSUtil_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/ECSUtil.sln
	TARGET ECSUtil
    RELEASE_CONFIGURATION ${ECSUtil_CONFIGURATION_RELEASE}
    DEBUG_CONFIGURATION ${ECSUtil_CONFIGURATION_DEBUG}
)

file(COPY ${SOURCE_PATH}/ECSUtil DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN *.h)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/ECSUtil/res)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(COPY ${SOURCE_PATH}/Debug/${ECSUtil_ARCH}/ECSUtil.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(COPY ${SOURCE_PATH}/Debug/${ECSUtil_ARCH}/ECSUtil.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(COPY ${SOURCE_PATH}/Release/${ECSUtil_ARCH}/ECSUtil.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY ${SOURCE_PATH}/Release/${ECSUtil_ARCH}/ECSUtil.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(COPY "${SOURCE_PATH}/Debug Lib Static/${ECSUtil_ARCH}/ECSUtil.lib" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(COPY "${SOURCE_PATH}/objDebug Lib Static/${ECSUtil_ARCH}/ECSUtil/ECSUtil.pdb" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(COPY "${SOURCE_PATH}/Release Lib Static/${ECSUtil_ARCH}/ECSUtil.lib" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY "${SOURCE_PATH}/objRelease Lib Static/${ECSUtil_ARCH}/ECSUtil/ECSUtil.pdb" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/ecsutil/copyright)

vcpkg_copy_pdbs()
