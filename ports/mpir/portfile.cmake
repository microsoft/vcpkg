include(${CMAKE_TRIPLET_FILE})
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Static building not supported yet")
endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mpir-2.7.2)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://mpir.org/mpir-2.7.2.tar.lz"
    FILENAME "mpir-2.7.2.tar.lz"
    SHA512 2635c167ddbba99364ec741373768e0675d34f94fad8912d5433b95e6fbfdb0510f5e94a707acc42048254bc658c52c6671bb0c0dac31267c4b82b00c3e74efa
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/build.vc14/dll_mpir_gc/dll_mpir_gc.vcxproj
)

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
	SET(BUILD_ARCH "Win32")
ELSE()
	SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

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

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mpir RENAME copyright)

vcpkg_copy_pdbs()
message(STATUS "Installing done")
