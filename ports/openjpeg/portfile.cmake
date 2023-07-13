vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uclouvain/openjpeg
    REF a5891555eb49ed7cc26b2901ea680acda136d811 #v2.5.0
    SHA512 f388d5770445152cd5ed18c61d2a56a6d2b88c2b56db0d460d09be36f3e6e40cf5be505aa63ac5975e07688be3dfe752080f4939bd792d42c61f4f8ddcaa1f0d
    HEAD_REF master
    PATCHES
        arm.patch
        no-wx.patch
        fix-static.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(feature_tools "tools" BUILD_JPIP_SERVER) # Requires pthread
    if("tools" IN_LIST FEATURES)
        list(APPEND FEATURE_OPTIONS "-DFCGI_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/fastcgi")
    endif()
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "jpip"          BUILD_JPIP
        ${feature_tools}
        "tools"         BUILD_VIEWER
        "tools"         BUILD_CODEC
        "tools"         BUILD_LUTS_GENERATOR
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
if("tools" IN_LIST FEATURES)
    list(APPEND TOOL_NAMES opj_compress opj_decompress opj_dump opj_dec_server opj_jpip_addxml opj_jpip_test opj_jpip_transcode)
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
