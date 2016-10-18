# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libodb-2.4.0)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.codesynthesis.com/download/odb/2.4/libodb-2.4.0.tar.gz"
    FILENAME "libodb-2.4.0.tar.gz"
    SHA512 f1311458634695eb6ba307ebfd492e3b260e7beb06db1c5c46df58c339756be4006322cdc4e42d055bf5b2ad14ce4656ddcafcc4e16c282034db8a77d255c3eb
)
vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_execute_required_process(COMMAND devenv libodb-vc12.sln /upgrade WORKING_DIRECTORY ${SOURCE_PATH} LOGNAME devenv_upgrade.log)
if(${TRIPLET_SYSTEM_ARCH} STREQUAL "x86")
    set(MSBUILD_PLATFORM "Win32")
else()
    set(MSBUILD_PLATFORM "x64")
endif()
vcpkg_build_msbuild(PROJECT_PATH "${SOURCE_PATH}\\libodb-vc12.sln" PLATFORM ${MSBUILD_PLATFORM})

if(${TRIPLET_SYSTEM_ARCH} STREQUAL "x86")
file(INSTALL ${SOURCE_PATH}/bin/odb-2.4-vc12.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin/odb-2.4-vc14.dll)
file(INSTALL ${SOURCE_PATH}/bin/odb-2.4-vc12.pdb DESTINATION ${CURRENT_PACKAGES_DIR}/bin/odb-2.4-vc14.pdb)
file(INSTALL ${SOURCE_PATH}/bin/odb-d-2.4-vc12.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/odb-2.4-vc14.dll)
file(INSTALL ${SOURCE_PATH}/bin/odb-d-2.4-vc12.pdb DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/odb-d-2.4-vc14.pdb)
file(INSTALL ${SOURCE_PATH}/lib/odb.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/lib/odb-d.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
elseif(${TRIPLET_SYSTEM_ARCH} STREQUAL "x64")
file(INSTALL ${SOURCE_PATH}/bin64/odb-2.4-vc12.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin/odb-2.4-vc14.dll)
file(INSTALL ${SOURCE_PATH}/bin64/odb-2.4-vc12.pdb DESTINATION ${CURRENT_PACKAGES_DIR}/bin/odb-2.4-vc14.pdb)
file(INSTALL ${SOURCE_PATH}/bin64/odb-d-2.4-vc12.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin/odb-2.4-vc14.dll)
file(INSTALL ${SOURCE_PATH}/bin64/odb-d-2.4-vc12.pdb DESTINATION ${CURRENT_PACKAGES_DIR}/bin/odb-d-2.4-vc14.pdb)
file(INSTALL ${SOURCE_PATH}/lib64/odb.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/lib64/odb-d.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endif()

#file(GLOB_RECURSE INCLUDE_FILES LIST_DIRECTORIES false RELATIVE ${SOURCE_DIR})
file(INSTALL ${SOURCE_PATH}/odb DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING
    PATTERN "*.h"
    PATTERN "*.hxx"
    PATTERN "*.ixx"
    PATTERN "*.txx")
# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libodb)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libodb/LICENSE ${CURRENT_PACKAGES_DIR}/share/libodb/copyright)
