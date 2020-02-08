include(vcpkg_common_functions)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "\n${PORT} does not support your system, only Windows for now. Please open a ticket issue on github.com/microsoft/vcpkg if necessary\n")
endif()

set(VERSION 1.14.0)
if (VCPKG_CRT_LINKAGE STREQUAL static)
    set(STATIC_PATCH "0001-static-crt-linkage.patch")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "http://dev-www.libreoffice.org/src/cppunit-${VERSION}.tar.gz"
    FILENAME "cppunit-${VERSION}.tar.gz"
    SHA512 4ea1da423c6f7ab37e4144689f593396829ce74d43872d6b10709c1ad5fbda4ee945842f7e9803592520ef81ac713e95a3fe130295bf048cd32a605d1959882e
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        ${STATIC_PATCH}
)

if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    set(BUILD_ARCH "Win32")
    set(OUTPUT_DIR "Win32")
elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
    set(BUILD_ARCH "x64")
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/src/cppunit/cppunit_dll.vcxproj
        PLATFORM ${BUILD_ARCH})
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/src/cppunit/cppunit.vcxproj
        PLATFORM ${BUILD_ARCH})
endif()

file(COPY ${SOURCE_PATH}/include/cppunit DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN *.h)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(COPY ${SOURCE_PATH}/lib/cppunitd_dll.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(COPY ${SOURCE_PATH}/lib/cppunitd_dll.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(COPY ${SOURCE_PATH}/lib/cppunit_dll.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY ${SOURCE_PATH}/lib/cppunit_dll.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(COPY ${SOURCE_PATH}/lib/cppunitd.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(COPY ${SOURCE_PATH}/lib/cppunit.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
endif()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/cppunit RENAME copyright)
