vcpkg_fail_port_install( ON_TARGET "uwp" "linux" "osx")

set(VERSION 3.9.5)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.apache.org/dist/activemq/activemq-cpp/${VERSION}/activemq-cpp-library-${VERSION}-src.tar.bz2"
    FILENAME "activemq-cpp-library-${VERSION}-src.tar.bz2"
    SHA512 83692d3dfd5ecf557fc88d204a03bf169ce6180bcff27be41b09409b8f7793368ffbeed42d98ef6374c6b6b477d9beb8a4a9ac584df9e56725ec59ceceaa6ae2
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/FunctionLevelLinkingOn.diff
)

set(RELEASE_CONF "ReleaseDLL")
set(DEBUG_CONF   "DebugDLL")

if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    set(BUILD_ARCH "Win32")
    set(OUTPUT_DIR "Win32")
elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
    set(BUILD_ARCH "x64")
    set(OUTPUT_DIR "Win64")
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()


vcpkg_build_msbuild(
     PROJECT_PATH ${SOURCE_PATH}/vs2010-build/activemq-cpp.vcxproj
     RELEASE_CONFIGURATION ${RELEASE_CONF}
     DEBUG_CONFIGURATION   ${DEBUG_CONF}
     PLATFORM ${BUILD_ARCH}
     USE_VCPKG_INTEGRATION
)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(
    COPY
    ${SOURCE_PATH}/vs2010-build/${BUILD_ARCH}/${RELEASE_CONF}/activemq-cpp.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)
file(
    COPY
    ${SOURCE_PATH}/vs2010-build/${BUILD_ARCH}/${RELEASE_CONF}/activemq-cpp.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
)
file(
    COPY
    ${SOURCE_PATH}/vs2010-build/${BUILD_ARCH}/${RELEASE_CONF}/activemq-cpp.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
)
file(
    COPY
    ${SOURCE_PATH}/vs2010-build/${BUILD_ARCH}/${DEBUG_CONF}/activemq-cppd.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
file(
    COPY
    ${SOURCE_PATH}/vs2010-build/${BUILD_ARCH}/${DEBUG_CONF}/activemq-cppd.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)
file(
    COPY
    ${SOURCE_PATH}/vs2010-build/${BUILD_ARCH}/${DEBUG_CONF}/activemq-cppd.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)

file(COPY ${SOURCE_PATH}/src/main/activemq DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN *.h)
file(COPY ${SOURCE_PATH}/src/main/cms      DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN *.h)
file(COPY ${SOURCE_PATH}/src/main/decaf    DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN *.h)
