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


set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/xerces-c-3.1.4)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www-us.apache.org/dist//xerces/c/3/sources/xerces-c-3.1.4.zip"
    FILENAME "xerces-c-3.1.4.zip"
    SHA512 3ba1bf38875bda8a294990dba73143cfd6dbfa158b17f4db1fd0ee9a08a078af969103200eaf8957756f8363c8a661983cc95124b4978eb2162dc0344a85fff8
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

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xercesc/NLS)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xercesc/util/MsgLoaders/ICU/resources)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/xerces-c)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/xerces-c/LICENSE ${CURRENT_PACKAGES_DIR}/share/xerces-c/copyright)

vcpkg_copy_pdbs()