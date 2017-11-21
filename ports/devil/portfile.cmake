include(vcpkg_common_functions)
include("${CMAKE_CURRENT_LIST_DIR}/convert_to_utf8.cmake")

set(DEVIL_VERSION 1.8.0)
set(DEVIL_HASH a3b6aa7c5302c0670ea1fa558c4fe71e85b2981102b452df35de1b1d531c0b78ed733bbbde252c75134d18bc3b00dd8b99032e4c9cc4fe028af771d4bad18801)
set(DEVIL_PATH ${CURRENT_BUILDTREES_DIR}/src/devil-${DEVIL_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/DentonW/DevIL/archive/v${DEVIL_VERSION}.zip"
    FILENAME "${DEVIL_VERSION}.zip"
    SHA512 ${DEVIL_HASH})
vcpkg_extract_source_archive(${ARCHIVE})

set(SOURCE_PATH ${DEVIL_PATH}/devIL)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(BUILD_SHARED_LIBS ON)
else()
    set(BUILD_SHARED_LIBS OFF)
endif()

convert_to_utf8("${SOURCE_PATH}/src-ILU/include/ilu_error/ilu_err-french.h")
convert_to_utf8("${SOURCE_PATH}/src-ILU/include/ilu_error/ilu_err-spanish.h")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DVCPKG_CMAKE_SYSTEM_NAME=${VCPKG_CMAKE_SYSTEM_NAME}
        -DUNICODE=ON
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
)
vcpkg_build_cmake()
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${DEVIL_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/devil RENAME copyright)

vcpkg_copy_pdbs()
