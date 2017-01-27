# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/xerces-c-3.1.4)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www-us.apache.org/dist//xerces/c/3/sources/xerces-c-3.1.4.zip"
    FILENAME "xerces-c-3.1.4.zip"
    SHA512 3ba1bf38875bda8a294990dba73143cfd6dbfa158b17f4db1fd0ee9a08a078af969103200eaf8957756f8363c8a661983cc95124b4978eb2162dc0344a85fff8
)
vcpkg_extract_source_archive(${ARCHIVE})

if (TRIPLET_SYSTEM_ARCH MATCHES "x86") 
     set(BUILD_ARCH "Win32") 
else() 
     set(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH}) 
endif() 


vcpkg_build_msbuild(
    #PROJECT_PATH ${SOURCE_PATH}/projects/Win32/VC14/xerces-all/xerces-all.sln
    PROJECT_PATH ${SOURCE_PATH}/projects/Win32/VC14/xerces-all/xercesLib/xercesLib.vcxproj
    PLATFORM ${BUILD_ARCH})


file(COPY ${SOURCE_PATH}/src/xercesc DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN *.hpp)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xercesc/NLS)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xercesc/util/MsgLoaders/ICU/resources)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/xerces)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/xerces/LICENSE ${CURRENT_PACKAGES_DIR}/share/xerces/copyright)
