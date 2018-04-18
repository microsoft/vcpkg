# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(STATUS "Only DLL builds are currently supported.")
    set(VCPKG_LIBRARY_LINKAGE "dynamic")
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    message(FATAL_ERROR "Only dynamic linking against the CRT is currently supported.")
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/xalan-c-1.11)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www-us.apache.org/dist/xalan/xalan-c/sources/xalan_c-1.11-src.zip"
    FILENAME "xalan_c-1.11-src.zip"
    SHA512 2e79a2c8f755c9660ffc94b26b6bd4b140685e05a88d8e5abb19a2f271383a3f2f398b173ef403f65dc33af75206214bd21ac012c39b4c0051b3a9f61f642fe6
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-ALLOW_RTCc_IN_STL.patch")

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
    PROJECT_PATH ${SOURCE_PATH}/c/projects/Win32/VC10/AllInOne/AllInOne.vcxproj
    PLATFORM ${BUILD_ARCH}
    USE_VCPKG_INTEGRATION
)

# This is needed to generate the required LocalMsgIndex.hpp header
vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/c/projects/Win32/VC10/Utils/XalanMsgLib/XalanMsgLib.vcxproj
    PLATFORM ${BUILD_ARCH}
    USE_VCPKG_INTEGRATION
)

file(COPY ${SOURCE_PATH}/c/Build/${OUTPUT_DIR}/VC10/Debug/XalanMessages_1_11D.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(COPY ${SOURCE_PATH}/c/Build/${OUTPUT_DIR}/VC10/Debug/Xalan-C_1_11D.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(COPY ${SOURCE_PATH}/c/Build/${OUTPUT_DIR}/VC10/Debug/Xalan-C_1D.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY ${SOURCE_PATH}/c/Build/${OUTPUT_DIR}/VC10/Release/XalanMessages_1_11.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/c/Build/${OUTPUT_DIR}/VC10/Release/Xalan-C_1_11.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/c/Build/${OUTPUT_DIR}/VC10/Release/Xalan-C_1.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(COPY ${SOURCE_PATH}/c/src/xalanc DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN *.hpp)

# LocalMsgIndex.hpp is here
file(COPY ${SOURCE_PATH}/c/Build/${OUTPUT_DIR}/VC10/Release/Nls/Include/LocalMsgIndex.hpp 
     DESTINATION ${CURRENT_PACKAGES_DIR}/include/xalanc/PlatformSupport)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/NLS)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/util/MsgLoaders/ICU/resources)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/TestXSLT)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/XalanExe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/XPathCAPI)

# Handle copyright
file(COPY ${SOURCE_PATH}/c/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/xalan-c)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/xalan-c/LICENSE ${CURRENT_PACKAGES_DIR}/share/xalan-c/copyright)

vcpkg_copy_pdbs()