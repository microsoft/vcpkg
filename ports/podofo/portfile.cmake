vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO podofo/podofo
    REF "${VERSION}"
    SHA512 e02b0b69ec720c0b89035c733ffb99f200f4624d61b79c1e6605166eec5c51cef6448987f0116c5feb34bd87850fedf248b6f98374661cb832faff72e4b8eefe
    PATCHES
        skip-pkg_config-check.patch
)
file(REMOVE_RECURSE
    "${SOURCE_PATH}/3rdparty/date"
    "${SOURCE_PATH}/3rdparty/fastfloat"
    "${SOURCE_PATH}/3rdparty/fmtlib"
    "${SOURCE_PATH}/3rdparty/tcbspan"
    "${SOURCE_PATH}/3rdparty/tclap"
    "${SOURCE_PATH}/3rdparty/utf8cpp"
    "${SOURCE_PATH}/3rdparty/utf8proc"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        fontmanager PODOFO_WITH_FONTMANAGER
)

if(VCPKG_TARGET_IS_WINDOWS AND "fontmanager" IN_LIST FEATURES AND NOT "fontconfig" IN_LIST FEATURES)
    # Use Win32 GDI when fontmanager is requested without Fontconfig.
    list(APPEND FEATURE_OPTIONS
        -DPODOFO_WITH_WIN32GDI_FONT_SEARCH=ON
    )
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PODOFO_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPODOFO_BUILD_LIB_ONLY=1
        -DPODOFO_BUILD_STATIC=${PODOFO_BUILD_STATIC}
        -DPODOFO_DEVENDOR_DATE=1
        -DPODOFO_DEVENDOR_FASTFLOAT=1
        -DPODOFO_DEVENDOR_FMT=1
        -DPODOFO_DEVENDOR_FMT_HEADER_ONLY=1
        -DPODOFO_DEVENDOR_TCBSPAN=1
        -DPODOFO_DEVENDOR_UTF8CPP=1
        -DPODOFO_DEVENDOR_UTF8PROC=1
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/podofo)

if(PODOFO_BUILD_STATIC)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/podofo/auxiliary/basedefs.h" "#ifdef PODOFO_STATIC" "#if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/COPYING.LGPL"
    "${SOURCE_PATH}/COPYING.MPL"
    "${SOURCE_PATH}/NOTICE"
)
