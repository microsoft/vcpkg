include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Sciter only supports Windows Desktop")
endif()

# header-only library
set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)

set(SCITER_REVISION db958b0f224feb0b5f5aa30a3e6f51e4bd0f1a2d)
set(SCITER_SHA f15bb818981abf53f077ee23fd3c3f23832881648414764f4b6c712c80d76dc758b375178042f233de5848fb580627c648b80155c8da13bc5d9f80a861dc3410)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    set(SCITER_ARCH x64)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    set(SCITER_ARCH x32)
endif()

# check out the `https://github.com/c-smile/sciter-sdk/archive/${SCITER_REVISION}.tar.gz`
# hash checksum can be obtained with `curl -L -o tmp.tgz ${URL} && vcpkg hash tmp.tgz`
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO c-smile/sciter-sdk
    REF ${SCITER_REVISION}
    SHA512 ${SCITER_SHA}
)

# install include directory
file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/sciter
    FILES_MATCHING
    PATTERN "*.cpp"
    PATTERN "*.mm"
    PATTERN "*.h"
    PATTERN "*.hpp"
)

set(SCITER_SHARE ${CURRENT_PACKAGES_DIR}/share/sciter)
set(SCITER_TOOLS ${CURRENT_PACKAGES_DIR}/tools/sciter)
set(TOOL_PERMS FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

# license
file(COPY ${SOURCE_PATH}/logfile.htm DESTINATION ${SCITER_SHARE})
file(COPY ${SOURCE_PATH}/license.htm DESTINATION ${SCITER_SHARE})
file(RENAME ${SCITER_SHARE}/license.htm ${SCITER_SHARE}/copyright)

# samples & widgets
file(COPY ${SOURCE_PATH}/samples DESTINATION ${SCITER_SHARE})
file(COPY ${SOURCE_PATH}/widgets DESTINATION ${SCITER_SHARE})

# tools
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL Linux AND VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    set(SCITER_BIN ${SOURCE_PATH}/bin.lnx/x64)

    file(INSTALL ${SOURCE_PATH}/bin.lnx/packfolder DESTINATION ${SCITER_TOOLS} ${TOOL_PERMS})
    file(INSTALL ${SOURCE_PATH}/bin.lnx/tiscript DESTINATION ${SCITER_TOOLS} ${TOOL_PERMS})

    file(INSTALL ${SCITER_BIN}/usciter DESTINATION ${SCITER_TOOLS} ${TOOL_PERMS})
    file(INSTALL ${SCITER_BIN}/inspector DESTINATION ${SCITER_TOOLS} ${TOOL_PERMS})
    file(INSTALL ${SCITER_BIN}/libsciter-gtk.so DESTINATION ${SCITER_TOOLS})

    file(INSTALL ${SCITER_BIN}/libsciter-gtk.so DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(INSTALL ${SCITER_BIN}/libsciter-gtk.so DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL Darwin)
    set(SCITER_BIN ${SOURCE_PATH}/bin.osx)

    file(INSTALL ${SCITER_BIN}/packfolder DESTINATION ${SCITER_TOOLS} ${TOOL_PERMS})
    file(INSTALL ${SCITER_BIN}/tiscript DESTINATION ${SCITER_TOOLS} ${TOOL_PERMS})

    file(INSTALL ${SCITER_BIN}/inspector.app DESTINATION ${SCITER_TOOLS})
    file(INSTALL ${SCITER_BIN}/sciter.app DESTINATION ${SCITER_TOOLS})
    file(INSTALL ${SCITER_BIN}/sciter-osx-64.dylib DESTINATION ${SCITER_TOOLS})

    # not sure whether there is a better way to do this, because
    # `file(INSTALL sciter.app FILE_PERMISSIONS EXECUTE)`
    # would mark everything as executable which is no go.
    execute_process(COMMAND sh -c "chmod +x sciter.app/Contents/MacOS/sciter" WORKING_DIRECTORY ${SCITER_TOOLS})
    execute_process(COMMAND sh -c "chmod +x inspector.app/Contents/MacOS/inspector" WORKING_DIRECTORY ${SCITER_TOOLS})

    file(INSTALL ${SCITER_BIN}/sciter-osx-64.dylib DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(INSTALL ${SCITER_BIN}/sciter-osx-64.dylib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

else()
    set(SCITER_BIN ${SOURCE_PATH}/bin.win/${SCITER_ARCH})
    set(SCITER_BIN32 ${SOURCE_PATH}/bin.win/x32)

    file(INSTALL ${SOURCE_PATH}/bin.win/packfolder.exe DESTINATION ${SCITER_TOOLS})
    file(INSTALL ${SOURCE_PATH}/bin.win/tiscript.exe DESTINATION ${SCITER_TOOLS})

    file(INSTALL ${SCITER_BIN32}/wsciter.exe DESTINATION ${SCITER_TOOLS})
    file(INSTALL ${SCITER_BIN32}/inspector.exe DESTINATION ${SCITER_TOOLS})
    file(INSTALL ${SCITER_BIN32}/sciter.dll DESTINATION ${SCITER_TOOLS})

    file(INSTALL ${SCITER_BIN}/sciter.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(INSTALL ${SCITER_BIN}/sciter.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(INSTALL ${SCITER_BIN}/tiscript-sqlite.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(INSTALL ${SCITER_BIN}/tiscript-sqlite.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

message(STATUS "Warning: Sciter requires manual deployment of the correct DLL files.")
