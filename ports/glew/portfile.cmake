include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/glew-2.0.0)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://sourceforge.net/projects/glew/files/glew/2.0.0/glew-2.0.0.tgz"
    FILENAME "glew-2.0.0.tgz"
    SHA512 e9bcd5f19a4495ce6511dfd76e64b4e4d958603c513ee9063eb9fe24fc6e0413f168620661230f1baef558f2f907cef7fe7ab2bdf957a6f7bda5fe96e9319c6a
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
	SET(BUILD_ARCH "Win32")
ELSEIF(TRIPLET_SYSTEM_ARCH MATCHES "arm")
	MESSAGE(FATAL_ERROR " ARM is currently not supported.")
ELSE()
	SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

# TODO: Maybe switch to glews' cmake build system in the future
FOREACH(LINKAGE shared static)
	if(NOT EXISTS ${SOURCE_PATH}/build/vc12/glew_${LINKAGE}14.vcxproj)
		message(STATUS "Upgrading " ${LINKAGE} " project")
		file(READ ${SOURCE_PATH}/build/vc12/glew_${LINKAGE}.vcxproj PROJ)
		string(REPLACE
			"<PlatformToolset>v120</PlatformToolset>"
			"<PlatformToolset>v140</PlatformToolset>"
			PROJ ${PROJ})
		string(REPLACE
			"opengl32.lib%"
			"opengl32.lib\;%"
			PROJ ${PROJ})
			
		if (LINKAGE STREQUAL "static")
			string(REPLACE
				"MultiThreadedDebugDLL"
				"MultiThreadedDebug"
				PROJ ${PROJ}
			)
		endif()
		file(WRITE ${SOURCE_PATH}/build/vc12/glew_${LINKAGE}14.vcxproj ${PROJ})
	endif()
ENDFOREACH(LINKAGE)
message(STATUS "Upgrading projects done")

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
	vcpkg_build_msbuild(
		PROJECT_PATH ${SOURCE_PATH}/build/vc12/glew_static14.vcxproj
	)
else()
	vcpkg_build_msbuild(
		PROJECT_PATH ${SOURCE_PATH}/build/vc12/glew_shared14.vcxproj
	)
endif()


message(STATUS "Installing")

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	file(INSTALL
		${SOURCE_PATH}/bin/Debug/${BUILD_ARCH}/glew32d.dll
		DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
	)
	file(INSTALL
		${SOURCE_PATH}/bin/Release/${BUILD_ARCH}/glew32.dll
		DESTINATION ${CURRENT_PACKAGES_DIR}/bin
	)
	file(INSTALL
		${SOURCE_PATH}/lib/Debug/${BUILD_ARCH}/glew32d.lib
		DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib RENAME glew32.lib
	)
	file(INSTALL
		${SOURCE_PATH}/lib/Release/${BUILD_ARCH}/glew32.lib
		DESTINATION ${CURRENT_PACKAGES_DIR}/lib
	)
else()
	file(INSTALL
		${SOURCE_PATH}/lib/Debug/${BUILD_ARCH}/glew32sd.lib
		DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib RENAME glew32.lib
	)
	file(INSTALL
		${SOURCE_PATH}/lib/Release/${BUILD_ARCH}/glew32s.lib
		DESTINATION ${CURRENT_PACKAGES_DIR}/lib RENAME glew32.lib
	)
endif()

file(INSTALL
    ${SOURCE_PATH}/include/GL
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/glew RENAME copyright)
vcpkg_copy_pdbs()
message(STATUS "Installing done")
