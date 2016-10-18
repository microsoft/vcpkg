# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libodb-sqlite-2.4.0)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.codesynthesis.com/download/odb/2.4/libodb-sqlite-2.4.0.tar.gz"
    FILENAME "libodb-sqlite-2.4.0.tar.gz"
    SHA512 af16da7c82cf8845ca3b393fbd8957a92b05ebc925a5191f20d414ab558345850073cd9c46457d0ef0edfb12ebcb27f267b934c9c69ef598380242fe920c8577
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_execute_required_process(COMMAND devenv libodb-sqlite-vc12.sln /upgrade WORKING_DIRECTORY ${SOURCE_PATH} LOGNAME devenv_upgrade.log)
set(ENV{INCLUDE} "$ENV{INCLUDE};${CURRENT_INSTALLED_DIR}/include")
set(ENV{LIB} "$ENV{LIB};${CURRENT_INSTALLED_DIR}/lib;${CURRENT_INSTALLED_DIR}/debug/lib")
if(${TRIPLET_SYSTEM_ARCH} STREQUAL "x86")
    set(MSBUILD_PLATFORM "Win32")
else()
    set(MSBUILD_PLATFORM "x64")
endif()
vcpkg_build_msbuild(PROJECT_PATH "${SOURCE_PATH}\\libodb-sqlite-vc12.sln" PLATFORM ${MSBUILD_PLATFORM}
                    OPTIONS "/p:useenv=true")

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libodb)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libodb/LICENSE ${CURRENT_PACKAGES_DIR}/share/libodb/copyright)