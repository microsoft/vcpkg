if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Sciter is only available under a free license as DLLs.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Sciter only supports Windows Desktop")
endif()

include(vcpkg_common_functions)

# header-only library
set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)

set(SCITER_REVISION a33d27afd10552c1d24b78d2e539097ebf1b1f60)
set(SCITER_SHA 3d819ba0cbfbd3b0c7355e40c3e6d40806f1a281528d6225835ec2340157afc4c7378cae533a0a2824f9bdfa37c8cdd35774b1e1362cfda3f1529b7bcea4d027)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    set(SCITER_ARCH 64)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    set(SCITER_ARCH 32)
endif()

# check out the `https://github.com/c-smile/sciter-sdk/archive/${SCITER_REVISION}.tar.gz`
# hash checksum can be obtained with `curl -L -o tmp.tgz ${URL} && vcpkg hash tmp.tgz`
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
file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/sciter
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
file(COPY ${SOURCE_PATH}/logfile.htm DESTINATION ${SCITER_SHARE})
file(COPY ${SOURCE_PATH}/license.htm DESTINATION ${SCITER_SHARE})
file(RENAME ${SCITER_SHARE}/license.htm ${SCITER_SHARE}/copyright)

# samples & widgets
file(COPY ${SOURCE_PATH}/samples DESTINATION ${SCITER_SHARE})
file(COPY ${SOURCE_PATH}/widgets DESTINATION ${SCITER_SHARE})

# tools
file(INSTALL ${SOURCE_PATH}/bin/packfolder.exe DESTINATION ${SCITER_TOOLS})
file(INSTALL ${SOURCE_PATH}/bin/tiscript.exe DESTINATION ${SCITER_TOOLS})

file(INSTALL ${SOURCE_PATH}/bin/${SCITER_ARCH}/sciter.exe DESTINATION ${SCITER_TOOLS})
file(INSTALL ${SOURCE_PATH}/bin/${SCITER_ARCH}/inspector.exe DESTINATION ${SCITER_TOOLS})
file(INSTALL ${SOURCE_PATH}/bin/${SCITER_ARCH}/sciter.dll DESTINATION ${SCITER_TOOLS})

file(INSTALL ${SOURCE_PATH}/bin/${SCITER_ARCH}/sciter.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(INSTALL ${SOURCE_PATH}/bin/${SCITER_ARCH}/sciter.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(INSTALL ${SOURCE_PATH}/bin/${SCITER_ARCH}/tiscript-sqlite.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(INSTALL ${SOURCE_PATH}/bin/${SCITER_ARCH}/tiscript-sqlite.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

message(STATUS "Warning: Sciter requires manual deployment of the correct DLL files.")
