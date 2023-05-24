vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libgd/libgd
    REF b5319a41286107b53daa0e08e402aa1819764bdc # gd-2.3.3
    SHA512 b4c6ca1d9575048de35a38b0db69e7380e160293133c1f72ae570f83ce614d4f2fd2615d217f7a0023e2265652c1089561b906beabca56c15e6ec0250e4394b2
    HEAD_REF master
    PATCHES
        control-build.patch
        fix-dependencies.cmake
        fix_msvc_build.patch
        fix-static-usage.patch
)

# Delete vendored Find modules
file(REMOVE
    "${SOURCE_PATH}/cmake/modules/CMakeParseArguments.cmake"
    "${SOURCE_PATH}/cmake/modules/FindFontConfig.cmake"
    "${SOURCE_PATH}/cmake/modules/FindFreetype.cmake"
    "${SOURCE_PATH}/cmake/modules/FindJPEG.cmake"
    "${SOURCE_PATH}/cmake/modules/FindPackageHandleStandardArgs.cmake"
    "${SOURCE_PATH}/cmake/modules/FindPNG.cmake"
    "${SOURCE_PATH}/cmake/modules/FindWEBP.cmake"
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        fontconfig   ENABLE_FONTCONFIG
        freetype     ENABLE_FREETYPE
        jpeg         ENABLE_JPEG
        tiff         ENABLE_TIFF
        png          ENABLE_PNG
        tools        ENABLE_TOOLS
        webp         ENABLE_WEBP
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_STATIC_LIBS=${BUILD_STATIC}
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
    OPTIONS_DEBUG
        -DENABLE_TOOLS=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(BUILD_STATIC)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/gd.h" "ifdef NONDLL" "if 1")
endif()
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    string(REPLACE "_dynamic" "" suffix "_${VCPKG_LIBRARY_LINKAGE}")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gdlib.pc" " -lgd" " -llibgd${suffix}")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gdlib.pc" " -lgd" " -llibgd${suffix}")
    endif()
endif()
vcpkg_fixup_pkgconfig()

if(ENABLE_TOOLS)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/bdftogd" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bdftogd")
    vcpkg_list(SET tool_names gdcmpgif)
    if(ENABLE_PNG)
        vcpkg_list(APPEND tool_names gdtopng pngtogd)
    endif()
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        if(ENABLE_FREETYPE AND ENABLE_JPEG)
            vcpkg_list(APPEND tool_names annotate)
        endif()
        if(ENABLE_PNG)
            vcpkg_list(APPEND tool_names webpng)
        endif()
    endif()
    vcpkg_copy_tools(TOOL_NAMES ${tool_names} AUTO_CLEAN)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
