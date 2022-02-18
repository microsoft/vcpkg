vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uclouvain/openjpeg
    REF 37ac30ceff6640bbab502388c5e0fa0bff23f505 #v2.4.0
    SHA512 7554d64701f1b51501a977bc165e61e4696d97f1f40e4c784c729824878a716c13ac378c6b2dd0d23a11d9e3fa316ff6fc817ca5a614ef4d6530db06a8f83971
    HEAD_REF master
    PATCHES 
        dll.location.patch
        fix-lrintf-to-opj_lrintf.patch
        Enable-tools-of-each-features.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "jpwl"          BUILD_JPWL
        "mj2"           BUILD_MJ2
        "jpip"          BUILD_JPIP
        "jp3d"          BUILD_JP3D
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_CODEC:BOOL=OFF
        -DBUILD_DOC:BOOL=OFF
        -DOPENJPEG_INSTALL_PACKAGE_DIR=share/openjpeg
        -DOPENJPEG_INSTALL_INCLUDE_DIR=include
        -DEXECUTABLE_OUTPUT_PATH=tools/${PORT}
        -DBUILD_PKGCONFIG_FILES=ON
        ${FEATURE_OPTIONS}
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

if(VCPKG_TARGET_IS_WINDOWS AND (NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL MinGW))
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libopenjp2.pc" "-lm" "")
    endif()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libopenjp2.pc" "-lm" "")
else()
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libopenjp2.pc" "-lm" "-lm -pthread")
    endif()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libopenjp2.pc" "-lm" "-lm -pthread")
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

set(TOOL_NAMES)
if("jpwl" IN_LIST FEATURES)
    list(APPEND TOOL_NAMES opj_compress opj_decompress opj_dump opj_jpwl_compress opj_jpwl_decompress)
endif()
if("mj2" IN_LIST FEATURES)
    list(APPEND TOOL_NAMES opj_compress opj_decompress opj_dump opj_mj2_compress opj_mj2_decompress opj_mj2_extract opj_mj2_wrap)
endif()
if("jpip" IN_LIST FEATURES)
    list(APPEND TOOL_NAMES opj_compress opj_decompress opj_dump opj_dec_server opj_jpip_addxml opj_jpip_test opj_jpip_transcode)
endif()
if("jp3d" IN_LIST FEATURES)
    list(APPEND TOOL_NAMES opj_jp3d_compress opj_jp3d_decompress)
endif()
if(TOOL_NAMES)
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
endif()

file(READ "${CURRENT_PACKAGES_DIR}/include/openjpeg.h" OPENJPEG_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "defined(OPJ_STATIC)" "1" OPENJPEG_H "${OPENJPEG_H}")
else()
    string(REPLACE "defined(OPJ_STATIC)" "0" OPENJPEG_H "${OPENJPEG_H}")
endif()
string(REPLACE "defined(DLL_EXPORT)" "0" OPENJPEG_H "${OPENJPEG_H}")
file(WRITE "${CURRENT_PACKAGES_DIR}/include/openjpeg.h" "${OPENJPEG_H}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
