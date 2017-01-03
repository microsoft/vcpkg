# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/json-c-177c401e02f50624372c0fde9c8dfcf2abfd9962)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/json-c/json-c/archive/177c401e02f50624372c0fde9c8dfcf2abfd9962.zip"
    FILENAME "json-c-177c401e02f50624372c0fde9c8dfcf2abfd9962.zip"
    SHA512 bbd49566cdc0fa0e0fdd8cb82f08859df1f66e486e83d1a74f3a95359a80c081c507b9e6f969df9959afecb1158a83e01cda6acdb8f2ff32f9c06b6f51a0f7d9
)
vcpkg_extract_source_archive(${ARCHIVE})

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    MESSAGE(FATAL_ERROR " dynamic linkage is not supported.")
endif()

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001-fix-crt-linkage.patch
)

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/json-c.vcxproj
)

message(STATUS "Installing")
file(INSTALL
    ${SOURCE_PATH}/Debug/json-c.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
file(INSTALL
    ${SOURCE_PATH}/Release/json-c.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)

file(GLOB public_headers ${SOURCE_PATH}/*.h)
file(INSTALL
    ${public_headers}
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/json-c
)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/json-c RENAME copyright)
vcpkg_copy_pdbs()
message(STATUS "Installing done")
