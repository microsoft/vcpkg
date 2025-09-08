string(REGEX REPLACE "^([0-9]+)[.]([0-9][.])" "\\1.0\\2" POPPLER_VERSION "${VERSION}")
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO poppler/poppler
    REF "poppler-${POPPLER_VERSION}"
    SHA512 24184d73503c77d614b20d8a2c2f8d77e40fd445ea2ceabdc5b77b5241ed45e053cc582af563284b1c9fd585bde3af5695cfe8fceff2efaf380499fb5f620f8c
    HEAD_REF master
    PATCHES
        export-unofficial-poppler.patch
        private-namespace.patch
)

set(POPPLER_PC_REQUIRES "freetype2 libjpeg libopenjp2 libpng libtiff-4 poppler-vcpkg-iconv")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cairo       WITH_Cairo
        cairo       VCPKG_LOCK_FIND_PACKAGE_CAIRO
        cms         ENABLE_LCMS
        cms         VCPKG_LOCK_FIND_PACKAGE_LCMS2
        curl        ENABLE_LIBCURL
        curl        VCPKG_LOCK_FIND_PACKAGE_CURL
        glib        ENABLE_GLIB
        glib        VCPKG_LOCK_FIND_PACKAGE_GLIB
        private-api ENABLE_UNSTABLE_API_ABI_HEADERS
        qt          ENABLE_QT6
        qt          VCPKG_LOCK_FIND_PACKAGE_Qt6
        zlib        ENABLE_ZLIB_UNCOMPRESS
)
if("fontconfig" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DFONT_CONFIGURATION=fontconfig")
    string(APPEND POPPLER_PC_REQUIRES " fontconfig")
elseif(VCPKG_TARGET_IS_ANDROID)
    list(APPEND FEATURE_OPTIONS "-DFONT_CONFIGURATION=android")
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

if("cms" IN_LIST FEATURES)
    string(APPEND POPPLER_PC_REQUIRES " lcms2")
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
        -DENABLE_RELOCATABLE=OFF # https://gitlab.freedesktop.org/poppler/poppler/-/issues/1209
        -DCMAKE_REQUIRE_FIND_PACKAGE_PkgConfig=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_OpenJPEG=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_JPEG=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_TIFF=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_PNG=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_Boost=ON
        -DENABLE_NSS3=OFF
        -DENABLE_GPGME=OFF
        -DRUN_GPERF_IF_PRESENT=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_ECM=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_GTK=OFF
        ${FEATURE_OPTIONS}
-DVCPKG_TRACE_FIND_PACKAGE=1
    MAYBE_UNUSED_VARIABLES
        GLIB2_MKENUMS_PYTHON
        VCPKG_LOCK_FIND_PACKAGE_CURL
        VCPKG_LOCK_FIND_PACKAGE_GLIB
        VCPKG_LOCK_FIND_PACKAGE_LCMS2
        VCPKG_LOCK_FIND_PACKAGE_CAIRO
        VCPKG_LOCK_FIND_PACKAGE_GTK
        VCPKG_LOCK_FIND_PACKAGE_Qt6
)
vcpkg_cmake_install()

configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-poppler-config.cmake" "${CURRENT_PACKAGES_DIR}/share/unofficial-poppler/unofficial-poppler-config.cmake" @ONLY)
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-poppler)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/poppler.pc" "Libs:" "Requires.private: ${POPPLER_PC_REQUIRES}\nLibs:")
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/poppler.pc" "Libs:" "Requires.private: ${POPPLER_PC_REQUIRES}\nLibs:")
endif()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
