# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(STATUS "Static libraries not supported; building dynamic instead")
    set(VCPKG_LIBRARY_LINKAGE "dynamic")
endif()
if (VCPKG_CRT_LINKAGE STREQUAL "static")
    message(STATUS "Static linking against the CRT not supported; building dynamic instead")
    set(VCPKG_CRT_LINKAGE "dynamic")
endif()


set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/xerces-c-Xerces-C_3_1_4)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/apache/xerces-c/archive/Xerces-C_3_1_4.zip"
    FILENAME "Xerces-C_3_1_4.zip"
    SHA512 3471134dacc4b2a25dece3c6eeab1d8143ca090f3652998c3a12c581e0351593bc0905334dd09c13864465c05952ca78f212a63d1c6c78bcd322d7aec23733cd
)
vcpkg_extract_source_archive(${ARCHIVE})

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
    #PROJECT_PATH ${SOURCE_PATH}/projects/Win32/VC14/xerces-all/xerces-all.sln
    PROJECT_PATH ${SOURCE_PATH}/projects/Win32/VC14/xerces-all/xercesLib/xercesLib.vcxproj
    PLATFORM ${BUILD_ARCH})

file(COPY ${SOURCE_PATH}/Build/${OUTPUT_DIR}/VC14/Debug/xerces-c_3_1D.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(COPY ${SOURCE_PATH}/Build/${OUTPUT_DIR}/VC14/Debug/xerces-c_3D.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY ${SOURCE_PATH}/Build/${OUTPUT_DIR}/VC14/Release/xerces-c_3_1.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/Build/${OUTPUT_DIR}/VC14/Release/xerces-c_3.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(COPY ${SOURCE_PATH}/src/xercesc DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN *.hpp)
# Certain headers under xercesc/util include .c files, so we need these copied over as well
file(COPY ${SOURCE_PATH}/src/xercesc DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN *.c)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xercesc/NLS)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xercesc/util/MsgLoaders/ICU/resources)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/xerces-c)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/xerces-c/LICENSE ${CURRENT_PACKAGES_DIR}/share/xerces-c/copyright)

vcpkg_copy_pdbs()