vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO freedesktop/poppler
    REF poppler-22.01.0
    SHA512 1edb8f0f4caa0a3f73ddb5a40e770d2590712f9bf8858c08854f80c9bd4ef1e5f75c2ec348e7369594b2d511ad96bfd52a7085ed64cc2f6b8e025feeb37357d0
    HEAD_REF master
)
file(REMOVE "${SOURCE_PATH}/cmake/Modules/FindFontconfig.cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cairo       WITH_Cairo
        curl        ENABLE_LIBCURL
        unstable    ENABLE_UNSTABLE_API_ABI_HEADERS
        zlib        ENABLE_ZLIB
)
if("fontconfig" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DFONT_CONFIGURATION=fontconfig")
elseif(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND FEATURE_OPTIONS "-DFONT_CONFIGURATION=win32")
else()
    list(APPEND FEATURE_OPTIONS "-DFONT_CONFIGURATION=generic")
endif()

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        -DBUILD_GTK_TESTS=OFF
        -DBUILD_QT5_TESTS=OFF
        -DBUILD_QT6_TESTS=OFF
        -DBUILD_CPP_TESTS=OFF
        -DBUILD_MANUAL_TESTS=OFF
        -DENABLE_UTILS=OFF
        -DENABLE_GLIB=OFF
        -DENABLE_GOBJECT_INTROSPECTION=OFF
        -DENABLE_QT5=OFF
        -DENABLE_QT6=OFF
        -DENABLE_CMS=none
        -DRUN_GPERF_IF_PRESENT=OFF
        -DENABLE_RELOCATABLE=ON
        -DWITH_NSS3=OFF
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
