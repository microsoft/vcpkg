string(REGEX REPLACE "^([0-9]+)[.]([0-9][.])" "\\1.0\\2" POPPLER_VERSION "${VERSION}")
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO poppler/poppler
    REF "poppler-${POPPLER_VERSION}"
    SHA512 18649364dc407080941b7c4010c0f26c1ce825d9ec49ff8e9ef298c62afb8d5bb77cea6a5cd1a74615190f433c265613dba42a6b7fdd80c2b5f00d372a31d21d
    HEAD_REF master
    PATCHES
        export-unofficial-poppler.patch
)
file(REMOVE "${SOURCE_PATH}/cmake/Modules/FindFontconfig.cmake")

set(POPPLER_PC_REQUIRES "freetype2 libjpeg libopenjp2 libpng libtiff-4 poppler-vcpkg-iconv")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cairo       WITH_Cairo
        curl        ENABLE_LIBCURL
        private-api ENABLE_UNSTABLE_API_ABI_HEADERS
        zlib        ENABLE_ZLIB
        glib        ENABLE_GLIB 
)
if("fontconfig" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DFONT_CONFIGURATION=fontconfig")
    string(APPEND POPPLER_PC_REQUIRES " fontconfig")
elseif(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND FEATURE_OPTIONS "-DFONT_CONFIGURATION=win32")
else()
    list(APPEND FEATURE_OPTIONS "-DFONT_CONFIGURATION=generic")
endif()
if("cairo" IN_LIST FEATURES)
    string(APPEND POPPLER_PC_REQUIRES " cairo")
endif()
if("curl" IN_LIST FEATURES)
    string(APPEND POPPLER_PC_REQUIRES " libcurl")
endif()
if("zlib" IN_LIST FEATURES)
    string(APPEND POPPLER_PC_REQUIRES " zlib")
endif()

vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        "-DGLIB2_MKENUMS_PYTHON=${PYTHON3}"
        -DBUILD_GTK_TESTS=OFF
        -DBUILD_QT5_TESTS=OFF
        -DBUILD_QT6_TESTS=OFF
        -DBUILD_CPP_TESTS=OFF
        -DBUILD_MANUAL_TESTS=OFF
        -DENABLE_UTILS=OFF
        -DENABLE_GOBJECT_INTROSPECTION=OFF
        -DENABLE_QT5=OFF
        -DENABLE_QT6=OFF
        -DENABLE_CMS=none
        -DRUN_GPERF_IF_PRESENT=OFF
        -DENABLE_RELOCATABLE=OFF # https://gitlab.freedesktop.org/poppler/poppler/-/issues/1209
        -DWITH_NSS3=OFF
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-poppler-config.cmake" "${CURRENT_PACKAGES_DIR}/share/unofficial-poppler/unofficial-poppler-config.cmake" @ONLY)
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-poppler)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/poppler.pc" "Libs:" "Requires.private: ${POPPLER_PC_REQUIRES}\nLibs:")
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/poppler.pc" "Libs:" "Requires.private: ${POPPLER_PC_REQUIRES}\nLibs:")
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
