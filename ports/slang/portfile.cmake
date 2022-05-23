set(SLANG_VER 0.23.13)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

if (VCPKG_TARGET_IS_WINDOWS)
	if (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
		vcpkg_download_distfile(
			ARCHIVE
			URLS "https://github.com/shader-slang/slang/releases/download/v${SLANG_VER}/slang-${SLANG_VER}-win64.zip"
			FILENAME "slang-${SLANG_VER}-win64.zip"
			SHA512 b7fb926426ee4ccd9e38ce1cb1b54b3034eeefbd38dbfba56d1559f9ff286521b4029ef411ecc8190ba426def2e775c4b747fb3eb8491bf7118d167185f65bbc
		)
		set(LIBDIR "windows-x64/release")
	elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
		vcpkg_download_distfile(
			ARCHIVE
			URLS "https://github.com/shader-slang/slang/releases/download/v${SLANG_VER}/slang-${SLANG_VER}-win32.zip"
			FILENAME "slang-${SLANG_VER}-win32.zip"
			SHA512 a42639e500e63a8fb9e18074c5d04671f6a2d871db03d2e99b48ec0bb46f6a80a75a8bf6fc3a8eed2b72505311b665dcd55e99b5305baedcc2a0f212ca32b770
		)
		set(LIBDIR "windows-x86/release")
	else()
		message(FATAL_ERROR "Currently unsupported platform, please implement me!")
	endif()

	vcpkg_extract_source_archive_ex(
		OUT_SOURCE_PATH BINDIST_PATH
		ARCHIVE "${ARCHIVE}"
		NO_REMOVE_ONE_LEVEL
	)

	file(INSTALL "${BINDIST_PATH}/bin/${LIBDIR}/slang-llvm.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
	file(INSTALL "${BINDIST_PATH}/bin/${LIBDIR}/slang-glslang.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
	file(INSTALL "${BINDIST_PATH}/bin/${LIBDIR}/slang.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
	file(INSTALL "${BINDIST_PATH}/bin/${LIBDIR}/gfx.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
	file(INSTALL "${BINDIST_PATH}/bin/${LIBDIR}/slang-llvm.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
	file(INSTALL "${BINDIST_PATH}/bin/${LIBDIR}/slang-glslang.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
	file(INSTALL "${BINDIST_PATH}/bin/${LIBDIR}/slang.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
	file(INSTALL "${BINDIST_PATH}/bin/${LIBDIR}/gfx.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
	
	file(INSTALL "${BINDIST_PATH}/bin/${LIBDIR}/slang.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
	file(INSTALL "${BINDIST_PATH}/bin/${LIBDIR}/gfx.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
	file(INSTALL "${BINDIST_PATH}/bin/${LIBDIR}/slang.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
	file(INSTALL "${BINDIST_PATH}/bin/${LIBDIR}/gfx.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
	
	file(INSTALL "${BINDIST_PATH}/bin/${LIBDIR}/slang-llvm.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
	file(INSTALL "${BINDIST_PATH}/bin/${LIBDIR}/slang-glslang.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
	file(INSTALL "${BINDIST_PATH}/bin/${LIBDIR}/slangc.exe" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
	file(INSTALL "${BINDIST_PATH}/bin/${LIBDIR}/slang.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

	file(GLOB HEADERS "${BINDIST_PATH}/*.h")
	file(INSTALL ${HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

else()
	message(FATAL_ERROR "Currently unsupported platform, please implement me!")
endif()

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO shader-slang/slang
	REF v${SLANG_VER}
	SHA512 d02e166c694c46df8402f94b3f117d04494465ffa2cf636913ddced6f6a614547032c78408d87b79eb5d9de14b97cf8d17087a41c7d038c546b9a294e7a1f3d7
	HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
