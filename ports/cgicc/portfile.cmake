include(vcpkg_common_functions)

if (TRIPLET_SYSTEM_ARCH STREQUAL "x64")
	message(FATAL_ERROR "Warning: x64 building not supported. Please build x86.")
endif()

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/cgicc-3.2.19)

vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnu.org/gnu/cgicc/cgicc-3.2.19.tar.gz"
    FILENAME "cgicc-3.2.19.tar.gz"
    SHA512 c361923cf3ac876bc3fc94dffd040d2be7cd44751d8534f4cfa3545e9f58a8ec35ebcd902a8ce6a19da0efe52db67506d8b02e5cc868188d187ce3092519abdf
)
vcpkg_extract_source_archive(${ARCHIVE})

configure_file(${SOURCE_PATH}/cgicc/config.h.in ${SOURCE_PATH}/config.h)
configure_file(${SOURCE_PATH}/cgicc/CgiDefs.h.in ${SOURCE_PATH}/CgiDefs.h)

file(COPY ${CURRENT_PORT_DIR}/cgicc.vcxproj DESTINATION ${SOURCE_PATH}/win)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
vcpkg_build_msbuild(
    PROJECT_PATH "${SOURCE_PATH}/win/cgicc.vcxproj"
    RELEASE_CONFIGURATION "Release"
    DEBUG_CONFIGURATION "Debug"
    PLATFORM ${PLATFORM}
)
else()
vcpkg_build_msbuild(
    PROJECT_PATH "${SOURCE_PATH}/win/cgicc.vcxproj"
    RELEASE_CONFIGURATION "Release_static"
    DEBUG_CONFIGURATION "Debug_static"
    PLATFORM ${PLATFORM}
)
endif()

vcpkg_copy_pdbs()

set (cgicc_HEADERS
	${SOURCE_PATH}/cgicc/Cgicc.h
	${SOURCE_PATH}/cgicc/CgiEnvironment.h
	${SOURCE_PATH}/cgicc/CgiInput.h
	${SOURCE_PATH}/cgicc/CgiUtils.h
	${SOURCE_PATH}/cgicc/FormEntry.h
	${SOURCE_PATH}/cgicc/FormFile.h
	${SOURCE_PATH}/cgicc/HTMLAtomicElement.h
	${SOURCE_PATH}/cgicc/HTMLAttribute.h
	${SOURCE_PATH}/cgicc/HTMLAttributeList.h
	${SOURCE_PATH}/cgicc/HTMLBooleanElement.h
	${SOURCE_PATH}/cgicc/HTMLClasses.h
	${SOURCE_PATH}/cgicc/HTMLDoctype.h
	${SOURCE_PATH}/cgicc/HTMLElement.h
	${SOURCE_PATH}/cgicc/HTMLElementList.h
	${SOURCE_PATH}/cgicc/HTTPContentHeader.h
	${SOURCE_PATH}/cgicc/HTTPCookie.h
	${SOURCE_PATH}/cgicc/HTTPHeader.h
	${SOURCE_PATH}/cgicc/HTTPHTMLHeader.h
	${SOURCE_PATH}/cgicc/HTTPPlainHeader.h
	${SOURCE_PATH}/cgicc/HTTPRedirectHeader.h
	${SOURCE_PATH}/cgicc/HTTPResponseHeader.h
	${SOURCE_PATH}/cgicc/HTTPStatusHeader.h
	${SOURCE_PATH}/cgicc/HTTPXHTMLHeader.h
	${SOURCE_PATH}/cgicc/MStreamable.h
	${SOURCE_PATH}/cgicc/XHTMLDoctype.h
	${SOURCE_PATH}/cgicc/XMLDeclaration.h
	${SOURCE_PATH}/cgicc/XMLPI.h
	${SOURCE_PATH}/CgiDefs.h
	${SOURCE_PATH}/config.h
)
file(INSTALL ${cgicc_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/cgicc)
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	file(INSTALL ${SOURCE_PATH}/win/Debug/cgicc.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
	file(INSTALL ${SOURCE_PATH}/win/Release/cgicc.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
endif()
file(INSTALL ${SOURCE_PATH}/win/Debug/cgicc.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL ${SOURCE_PATH}/win/Release/cgicc.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING.DOC DESTINATION ${CURRENT_PACKAGES_DIR}/share/cgicc RENAME copyright)
