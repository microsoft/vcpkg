set(FLINT_VERSION 2.5.2)
set(FLINT_HASH "8606b369af505d5fcedd05d95fcd04afac2a916fc5291501c56785891cfdb2f9bc98700b2d05afd1d9482fb96df2a8c8bf1cd0e5696df46775df9fa743eb900b")

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.flintlib.org/flint-${FLINT_VERSION}.zip"
    FILENAME "flint-${FLINT_VERSION}.zip"
    SHA512 ${FLINT_HASH}
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        lib_flint.patch
        dll_flint.patch
)

set(MSVC_VERSION 14)

file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
file(COPY ${SOURCE_PATH} DESTINATION ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
get_filename_component(SOURCE_DIR_NAME "${SOURCE_PATH}" NAME)

# Use fresh copy of sources for building and modification
set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${SOURCE_DIR_NAME}")

file(TO_NATIVE_PATH ${CURRENT_INSTALLED_DIR} NATIVE_INSTALLED_DIR)
configure_file(
	"${SOURCE_PATH}/build.vc${MSVC_VERSION}/dll_flint/dll_flint.vcxproj" "${SOURCE_PATH}/build.vc${MSVC_VERSION}/dll_flint/dll_flint.vcxproj" @ONLY
)
configure_file(
	"${SOURCE_PATH}/build.vc${MSVC_VERSION}/lib_flint/lib_flint.vcxproj" "${SOURCE_PATH}/build.vc${MSVC_VERSION}/lib_flint/lib_flint.vcxproj" @ONLY
)

file(RENAME "${SOURCE_PATH}/fmpz-conversions-gc.in" "${SOURCE_PATH}/fmpz-conversions.h")

IF (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
	file(RENAME "${SOURCE_PATH}/fft_tuning32.in" "${SOURCE_PATH}/fft_tuning.h")
ELSE()
	file(RENAME "${SOURCE_PATH}/fft_tuning64.in" "${SOURCE_PATH}/fft_tuning.h")
ENDIF()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
	vcpkg_build_msbuild(
		PROJECT_PATH ${SOURCE_PATH}/build.vc${MSVC_VERSION}/dll_flint/dll_flint.vcxproj
	)
else()
	vcpkg_build_msbuild(
		PROJECT_PATH ${SOURCE_PATH}/build.vc${MSVC_VERSION}/lib_flint/lib_flint.vcxproj
	)
endif()

IF (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
	SET(BUILD_ARCH "Win32")
ELSE()
	SET(BUILD_ARCH ${VCPKG_TARGET_ARCHITECTURE})
ENDIF()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
	file(GLOB FLINT_HEADERS "${SOURCE_PATH}/dll/${BUILD_ARCH}/Release/*.h")
	file(INSTALL
		${FLINT_HEADERS}
		DESTINATION ${CURRENT_PACKAGES_DIR}/include/flint
	)
	file(INSTALL
		${SOURCE_PATH}/build.vc${MSVC_VERSION}/dll_flint/${BUILD_ARCH}/Release/dll_flint.dll
		DESTINATION ${CURRENT_PACKAGES_DIR}/bin
	)
	file(INSTALL
		${SOURCE_PATH}/build.vc${MSVC_VERSION}/dll_flint/${BUILD_ARCH}/Debug/dll_flint.dll
		DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
	)
	file(INSTALL
		${SOURCE_PATH}/build.vc${MSVC_VERSION}/dll_flint/${BUILD_ARCH}/Release/dll_flint.lib
		DESTINATION ${CURRENT_PACKAGES_DIR}/lib
		RENAME flint.lib
	)
	file(INSTALL
		${SOURCE_PATH}/build.vc${MSVC_VERSION}/dll_flint/${BUILD_ARCH}/Debug/dll_flint.lib
		DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
		RENAME flint.lib
	)
	vcpkg_copy_pdbs()
else()
	file(GLOB FLINT_HEADERS "${SOURCE_PATH}/lib/${BUILD_ARCH}/Release/*.h")
	file(INSTALL
		${FLINT_HEADERS}
		DESTINATION ${CURRENT_PACKAGES_DIR}/include/flint
	)
	file(INSTALL
		${SOURCE_PATH}/build.vc${MSVC_VERSION}/lib_flint/${BUILD_ARCH}/Release/lib_flint.lib
		DESTINATION ${CURRENT_PACKAGES_DIR}/lib
		RENAME flint.lib
	)
	file(INSTALL
		${SOURCE_PATH}/build.vc${MSVC_VERSION}/lib_flint/${BUILD_ARCH}/Debug/lib_flint.lib
		DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
		RENAME flint.lib
	)
endif()

file(INSTALL
	${SOURCE_PATH}/gpl-2.0.txt
	DESTINATION ${CURRENT_PACKAGES_DIR}/share/flint
	RENAME copyright
)

message(STATUS "Installing done")
