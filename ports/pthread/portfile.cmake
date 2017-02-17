# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/pthread-win32-19fd5054b29af1b4e3b3278bfffbb6274c6c89f5)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/GerHobbelt/pthread-win32/archive/19fd5054b29af1b4e3b3278bfffbb6274c6c89f5.zip"
    FILENAME "19fd5054b29af1b4e3b3278bfffbb6274c6c89f5.zip"
    SHA512 7b1ecae505b805dce3ffe6d7fb3e5e62aba25da991efb8899f8fa24fbe60317e3b391b34cc4a8ca8cda5e6a6f96f0ba95a0523b99812ede46a12711cc80daca8
)
vcpkg_extract_source_archive(${ARCHIVE})

# Map from triplet "x86" to "win32" as used in the vcxproj file.
if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(MSBUILD_PLATFORM "Win32_MSVC2015")
else ()
    set(MSBUILD_PLATFORM ${TRIPLET_SYSTEM_ARCH})
endif()

message(STATUS "Building Release")
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_build_msbuild(
            PROJECT_PATH ${SOURCE_PATH}/pthread.2015.vcxproj
            RELEASE_CONFIGURATION Release
            DEBUG_CONFIGURATION Debug
        )
    file(INSTALL
        ${SOURCE_PATH}/bin/${MSBUILD_PLATFORM}.Debug/pthread_dll.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )
    file(INSTALL
        ${SOURCE_PATH}/bin/${MSBUILD_PLATFORM}.Release/pthread_dll.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )
    file(INSTALL
        ${SOURCE_PATH}/bin/${MSBUILD_PLATFORM}.Debug/pthread_dll.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )
    file(INSTALL
        ${SOURCE_PATH}/bin/${MSBUILD_PLATFORM}.Release/pthread_dll.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )
    vcpkg_copy_pdbs()
endif()

file(INSTALL
    ${SOURCE_PATH}/pthread.h
    ${SOURCE_PATH}/sched.h
    ${SOURCE_PATH}/semaphore.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/pthread)
file(COPY ${SOURCE_PATH}/COPYING.FSF DESTINATION ${CURRENT_PACKAGES_DIR}/share/pthread)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pthread/COPYING.FSF ${CURRENT_PACKAGES_DIR}/share/pthread/copyright)
