vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uclouvain/openjpeg
    REF "v${VERSION}"
    SHA512 24c058b3e0710e689ba7fd6bce8a88353ce64e825b2e5bbf6b00ca3f2a2ec1e9c70a72e0252a5c89d10c537cf84d55af54bf2f16c58ca01db98c2018cf132e1a
    HEAD_REF master
    PATCHES
        third-party.diff
        openjpip-static.diff
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "jpip"          BUILD_JPIP
        "tools"         BUILD_CODEC
        "tools"         BUILD_LUTS_GENERATOR
)

if(NOT VCPKG_TARGET_IS_WINDOWS AND "tools" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS 
        -DBUILD_JPIP_SERVER=ON
        "-DFCGI_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/fastcgi"
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_DOC:BOOL=OFF
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DCMAKE_DISABLE_FIND_PACKAGE_Java=ON
        -DOPENJPEG_INSTALL_SUBDIR=.
        -DOPENJPEG_INSTALL_PACKAGE_DIR=share/openjpeg
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_Java
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libopenjp2.pc" "-lm" "")
    endif()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libopenjp2.pc" "-lm" "")
else()
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libopenjp2.pc" "-lm" "-lm -pthread")
    endif()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libopenjp2.pc" "-lm" "-lm -pthread")
endif()

set(TOOL_NAMES "")
if("tools" IN_LIST FEATURES)
    list(APPEND TOOL_NAMES opj_compress opj_decompress opj_dump opj_dec_server opj_jpip_addxml opj_jpip_test opj_jpip_transcode)
endif()
if(TOOL_NAMES)
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(WRITE "${CURRENT_PACKAGES_DIR}/include/openjpeg\.h" [[
/* vcpkg VS legacy compatibility */
#include "openjpeg-2.5/openjpeg.h"
]])
    file(WRITE "${CURRENT_PACKAGES_DIR}/include/opj_config\.h" [[
/* vcpkg VS legacy compatibility */
#include "openjpeg-2.5/opj_config.h"
]])
endif()

file(READ "${CURRENT_PACKAGES_DIR}/include/openjpeg-2.5/openjpeg\.h" OPENJPEG_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "defined(OPJ_STATIC)" "1" OPENJPEG_H "${OPENJPEG_H}")
else()
    string(REPLACE "defined(OPJ_STATIC)" "0" OPENJPEG_H "${OPENJPEG_H}")
endif()
string(REPLACE "defined(DLL_EXPORT)" "0" OPENJPEG_H "${OPENJPEG_H}")
file(WRITE "${CURRENT_PACKAGES_DIR}/include/openjpeg-2.5/openjpeg\.h" "${OPENJPEG_H}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
