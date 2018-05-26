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

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/xerces-c
    REF Xerces-C_3_1_4
    SHA512 6dc3e4bb68bc32a0e8ec6dcc7ec67e21239a79c909d08ccc16c96dc5de4e73800993d1c09f589606925507baf0b2a9bf6037d28c84dae826935bf1f7a151071e
    HEAD_REF master
)

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
file(COPY ${SOURCE_PATH}/LICENSE ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/xerces-c)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/xerces-c/LICENSE ${CURRENT_PACKAGES_DIR}/share/xerces-c/copyright)

vcpkg_copy_pdbs()