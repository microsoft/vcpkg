#header-only library
include(vcpkg_common_functions)

set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)

set(SCITER_VERSION 4.0.0.7)
set(SCITER_REVISION 7ce5faadcea7ddcbf116fde6f8a9c837ca32ae69)
set(SCITER_SHA 47a65647fdfb24f27c790f996467f85ce2be8c13a8b7a8ced5e9b75eff210f2c3fe635653892cd5aae82482f0a1206188bdbbbb54b52176eea6e98c46080aeed)
set(SCITER_SRC ${CURRENT_BUILDTREES_DIR}/src/sciter-sdk-${SCITER_REVISION})

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
  set(SCITER_ARCH 64)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
  set(SCITER_ARCH 32)
endif()

# unpack
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/c-smile/sciter-sdk/archive/${SCITER_REVISION}.zip"
    FILENAME "sciter-sdk-${SCITER_VERSION}.zip"
    SHA512 ${SCITER_SHA}
)
vcpkg_extract_source_archive(${ARCHIVE})

# include
file(INSTALL ${SCITER_SRC}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/sciter
  FILES_MATCHING
  PATTERN "sciter-gtk-main.cpp" EXCLUDE
  PATTERN "sciter-osx-main.mm" EXCLUDE
  PATTERN "*.cpp"
  PATTERN "*.h"
  PATTERN "*.hpp"
  )

set(SCITER_SHARE ${CURRENT_PACKAGES_DIR}/share/sciter)

# license
file(COPY ${SCITER_SRC}/logfile.htm DESTINATION ${SCITER_SHARE})
file(COPY ${SCITER_SRC}/license.htm DESTINATION ${SCITER_SHARE})
file(RENAME ${SCITER_SHARE}/license.htm ${SCITER_SHARE}/copyright)

# samples & widgets
file(COPY ${SCITER_SRC}/samples DESTINATION ${SCITER_SHARE})
file(COPY ${SCITER_SRC}/widgets DESTINATION ${SCITER_SHARE})

# tools
file(INSTALL ${SCITER_SRC}/bin/packfolder.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(INSTALL ${SCITER_SRC}/bin/tiscript.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools)

file(INSTALL ${SCITER_SRC}/bin/${SCITER_ARCH}/sciter.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(INSTALL ${SCITER_SRC}/bin/${SCITER_ARCH}/inspector.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	file(INSTALL ${SCITER_SRC}/bin/${SCITER_ARCH}/sciter.dll DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
endif()

# bin
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	file(INSTALL ${SCITER_SRC}/bin/${SCITER_ARCH}/sciter.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
	file(INSTALL ${SCITER_SRC}/bin/${SCITER_ARCH}/sciter.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
	file(INSTALL ${SCITER_SRC}/bin/${SCITER_ARCH}/tiscript-sqlite.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
	file(INSTALL ${SCITER_SRC}/bin/${SCITER_ARCH}/tiscript-sqlite.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
	message(WARNING "Sciter requires sciter.dll to run. Download it manually or install dynamic package.")
endif()
