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

set(ECSUTIL_VERSION "v1.0.1.2")
set(ECSUtil_HASH 399aec10a625ee6eb8f7869005b9221a1e4930c7e8774c20467ddc0e86312e7e1224fb29a1b54d3c9669b78708a23db548195f8973a19eb5559338f600688888)
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
	if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
	    set(ECSUtil_CONFIGURATION_RELEASE "Release Lib")
		set(ECSUtil_CONFIGURATION_DEBUG "Debug Lib")
	else()
	    set(ECSUtil_CONFIGURATION_RELEASE "Release Lib Static")
		set(ECSUtil_CONFIGURATION_DEBUG "Debug Lib Static")
	endif()
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/EMCECS/ecs-object-client-windows-cpp/releases/download/${ECSUTIL_VERSION}/ecs-object-client-windows-cpp.${ECSUTIL_VERSION}.zip"
    FILENAME "ecs-object-client-windows-cpp.${ECSUTIL_VERSION}.zip"
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
	if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
		file(COPY "${SOURCE_PATH}/Debug Lib/${ECSUtil_ARCH}/ECSUtil.lib" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
		file(COPY "${SOURCE_PATH}/objDebug Lib/${ECSUtil_ARCH}/ECSUtil/ECSUtil.pdb" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
		file(COPY "${SOURCE_PATH}/Release Lib/${ECSUtil_ARCH}/ECSUtil.lib" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
		file(COPY "${SOURCE_PATH}/objRelease Lib/${ECSUtil_ARCH}/ECSUtil/ECSUtil.pdb" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
	else()
		file(COPY "${SOURCE_PATH}/Debug Lib Static/${ECSUtil_ARCH}/ECSUtil.lib" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
		file(COPY "${SOURCE_PATH}/objDebug Lib Static/${ECSUtil_ARCH}/ECSUtil/ECSUtil.pdb" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
		file(COPY "${SOURCE_PATH}/Release Lib Static/${ECSUtil_ARCH}/ECSUtil.lib" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
		file(COPY "${SOURCE_PATH}/objRelease Lib Static/${ECSUtil_ARCH}/ECSUtil/ECSUtil.pdb" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
	endif()
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/ecsutil/copyright)

vcpkg_copy_pdbs()
