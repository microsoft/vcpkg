if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(WARNING "Warning: Sciter requires sciter.dll to run. Download it manually or install dynamic package.")
endif()

include(vcpkg_common_functions)

# header-only library
set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)

set(SCITER_VERSION 4.0.0.9)
set(SCITER_REVISION 43565156c373f9635cc491551b870a948d4d6f37)
set(SCITER_SHA 6c50822c46784a8b2114973dffa8ec4041c69f84303507fdcde425dbac8d698dd6241a209cdc0ae0663751ed0f78d92f7b0c26794417f374978bfb3e33bf004c)
set(SCITER_SRC ${CURRENT_BUILDTREES_DIR}/src/sciter-sdk-${SCITER_REVISION})

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    set(SCITER_ARCH 64)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    set(SCITER_ARCH 32)
endif()

# check out
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO c-smile/sciter-sdk
    REF ${SCITER_REVISION}
    SHA512 ${SCITER_SHA}
)

# disable stdafx.h
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001_patch_stdafx.patch
)

# install include directory
file(INSTALL ${SCITER_SRC}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/sciter
    FILES_MATCHING
    PATTERN "sciter-gtk-main.cpp" EXCLUDE
    PATTERN "sciter-osx-main.mm" EXCLUDE
    PATTERN "*.cpp"
    PATTERN "*.h"
    PATTERN "*.hpp"
)

set(SCITER_SHARE ${CURRENT_PACKAGES_DIR}/share/sciter)
set(SCITER_TOOLS ${CURRENT_PACKAGES_DIR}/tools/sciter)

# license
file(COPY ${SCITER_SRC}/logfile.htm DESTINATION ${SCITER_SHARE})
file(COPY ${SCITER_SRC}/license.htm DESTINATION ${SCITER_SHARE})
file(RENAME ${SCITER_SHARE}/license.htm ${SCITER_SHARE}/copyright)

# samples & widgets
file(COPY ${SCITER_SRC}/samples DESTINATION ${SCITER_SHARE})
file(COPY ${SCITER_SRC}/widgets DESTINATION ${SCITER_SHARE})

# tools
file(INSTALL ${SCITER_SRC}/bin/packfolder.exe DESTINATION ${SCITER_TOOLS})
file(INSTALL ${SCITER_SRC}/bin/tiscript.exe DESTINATION ${SCITER_TOOLS})

file(INSTALL ${SCITER_SRC}/bin/${SCITER_ARCH}/sciter.exe DESTINATION ${SCITER_TOOLS})
file(INSTALL ${SCITER_SRC}/bin/${SCITER_ARCH}/inspector.exe DESTINATION ${SCITER_TOOLS})

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    # DLLs should not be present in a static build
    file(INSTALL ${SCITER_SRC}/bin/${SCITER_ARCH}/sciter.dll DESTINATION ${SCITER_TOOLS})
endif()

# bin
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	file(INSTALL ${SCITER_SRC}/bin/${SCITER_ARCH}/sciter.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
	file(INSTALL ${SCITER_SRC}/bin/${SCITER_ARCH}/sciter.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
	file(INSTALL ${SCITER_SRC}/bin/${SCITER_ARCH}/tiscript-sqlite.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
	file(INSTALL ${SCITER_SRC}/bin/${SCITER_ARCH}/tiscript-sqlite.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
