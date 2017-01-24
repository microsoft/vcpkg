include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mpir-2.7.2)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://mpir.org/mpir-2.7.2.tar.bz2"
    FILENAME "mpir-2.7.2.tar.bz2"
    SHA512 8436a0123201f9e30130ea340331c5a6445dddb58ce1f6c6a3a8303c310ac5b3c279c83b5c520a757cba82c2b14e92da44583e0eec287090cf69cbb29d516a9c
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
	vcpkg_build_msbuild(
		PROJECT_PATH ${SOURCE_PATH}/build.vc14/dll_mpir_gc/dll_mpir_gc.vcxproj
	)
else()
	vcpkg_build_msbuild(
		PROJECT_PATH ${SOURCE_PATH}/build.vc14/lib_mpir_gc/lib_mpir_gc.vcxproj
	)
endif()

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
	SET(BUILD_ARCH "Win32")
ELSE()
	SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
	file(INSTALL
		${SOURCE_PATH}/dll/${BUILD_ARCH}/Debug/gmp.h
		${SOURCE_PATH}/dll/${BUILD_ARCH}/Debug/gmpxx.h
		${SOURCE_PATH}/dll/${BUILD_ARCH}/Debug/mpir.h
		${SOURCE_PATH}/dll/${BUILD_ARCH}/Debug/mpirxx.h
		DESTINATION ${CURRENT_PACKAGES_DIR}/include
	)
	file(INSTALL
		${SOURCE_PATH}/dll/${BUILD_ARCH}/Debug/mpir.dll
		${SOURCE_PATH}/dll/${BUILD_ARCH}/Debug/mpir.pdb
		DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
	)
	file(INSTALL
		${SOURCE_PATH}/dll/${BUILD_ARCH}/Release/mpir.dll
		${SOURCE_PATH}/dll/${BUILD_ARCH}/Release/mpir.pdb
		DESTINATION ${CURRENT_PACKAGES_DIR}/bin
	)
	file(INSTALL
		${SOURCE_PATH}/dll/${BUILD_ARCH}/Debug/mpir.lib
		DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
	)
	file(INSTALL
		${SOURCE_PATH}/dll/${BUILD_ARCH}/Release/mpir.lib
		DESTINATION ${CURRENT_PACKAGES_DIR}/lib
	)
	file(INSTALL ${SOURCE_PATH}/COPYING.lib DESTINATION ${CURRENT_PACKAGES_DIR}/share/mpir RENAME copyright)
	vcpkg_copy_pdbs()
else()
	file(INSTALL
		${SOURCE_PATH}/lib/${BUILD_ARCH}/Debug/gmp.h
		${SOURCE_PATH}/lib/${BUILD_ARCH}/Debug/gmpxx.h
		${SOURCE_PATH}/lib/${BUILD_ARCH}/Debug/mpir.h
		${SOURCE_PATH}/lib/${BUILD_ARCH}/Debug/mpirxx.h
		DESTINATION ${CURRENT_PACKAGES_DIR}/include
	)
	file(INSTALL
		${SOURCE_PATH}/lib/${BUILD_ARCH}/Debug/mpir.lib
		DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
	)
	file(INSTALL
		${SOURCE_PATH}/lib/${BUILD_ARCH}/Release/mpir.lib
		DESTINATION ${CURRENT_PACKAGES_DIR}/lib
	)
	file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mpir RENAME copyright)
endif()

message(STATUS "Installing done")
